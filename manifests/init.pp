# Class: procps
#
# This module manages procps
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class procps {

  package { 'procps':
    ensure => installed,
  }

  case $::operatingsystem {
    /(?i-mx:debian|ubuntu)/: {
      file { '/etc/sysctl.conf':
        ensure => present,
        require => Package['procps'],
      }

      file { '/etc/sysctl.d':
        ensure => directory,
        checksum => mtime,
        require => Package['procps'],
        notify => Service['procps'],
      }
      File['/etc/sysctl.d'] -> Procps::Config <| |> -> Service['procps']

      service { 'procps':
#        ensure => running,
        require => Package['procps'],
      }
    }
    /(?i-mx:redhat|centos)/: {
      concat { '/etc/sysctl.conf':
        require => Package['procps']
      }
      procps::config { 'redhat-default':
        content => template('procps/redhat-default.erb'),
        order => '00',
      }
      exec { '/sbin/sysctl -e -p':
        subscribe => Concat['/etc/sysctl.conf'],
        refreshonly => true,
      }
    }
  }
}

# Definition: procps::config
#
# set config file to /etc/sysctl.d/.
#
# Parameters:
#   $content: required, pass through to file resource.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#   procps::config { 'ipforwarding':
#     content => 'net.ipv4.ip_forward=1',
#   }
define procps::config ( $content, $order = '' ) {
# http://libtune.sourceforge.net/doc/tunables.list.02.html
  case $::operatingsystem {
    /(?i-mx:debian|ubuntu)/: {
      file { "/etc/sysctl.d/${name}.conf":
        content => $content,
      }
    }
    /(?i-mx:redhat|centos)/: {
      concat::fragment { "procps-config-$name":
        target => '/etc/sysctl.conf',
        content => $content,
        order => $order,
      }
    }
  }
}
