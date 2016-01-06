# == Class: sssd::authconfig
#
# Enable SSSD authentication in PAM and NSS.
#
# === Authors
#
# Evgeny Zislis <ezislis@adaptavist.com>
#
# === Copyright
#
# Copyright 2014 Adaptavist Ltd, unless otherwise noted.
#

class sssd::authconfig (
  $auth_command       = 'authconfig --enablesssd --enablesssdauth --enablelocauthorize --enableldapauth --enableldap --kickstart --update',
  $authconfig_package = 'authconfig'
) {
  if (!defined(Package[$authconfig_package])) {
    package { $authconfig_package:
      ensure => installed
    }
  }

  exec { 'authconfig-sssd':
    command => $auth_command,
    require => Package[$authconfig_package]
  }
}
