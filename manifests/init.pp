# == Class: sssd
#
# Manage SSSD authentication and configuration.
# Currently supported AD and default ldap set as default for ldap server
# Default will create standard ldap dirs structure, adjust nsswitch.conf
#
# === Parameters
# [*type*]
# type of ldap server, supported options are default and ad
#
# [*ldap_search_base*]
# default ldap params passed to sssd.conf
#
# [*cert_name*]
# Certificate name, default is undef, certificate must be present in
# files/sssd/${cert_name} of your puppetmaster
#
# [*ldap_default_bind_uid*]
# Bind uid, default is undef
#
# [*ldap_default_authtok*]
# default ldap params passed to sssd.conf, default set to undef
#
# [*domains*]
# Define domain lookup order for sssd.
#
# [*filter_users*]
# Filter to exclude users from sssd lookups.
#
# [*filter_groups*]
# Filter to exclude groups from sssd lookups.
#
# [*custom_template*]
# Used to specify an alternate template instead of the one used by the module.
#
# [*debug_level*]
# Used to specify the debug level.
#
# === Example
#
# class { 'sssd':
#   domains => [ 'example.com', 'another.com' ],
# }
#
# === Authors
#
# Evgeny Zislis <ezislis@adaptavist.com>
#
# === Copyright
#
# Copyright 2014 Adaptavist Ltd, unless otherwise noted.
#
class sssd (
  $type                  = 'default',
  $domains               = [],
  $filter_users          = [ 'root' ],
  $filter_groups         = [ 'root' ],
  $custom_template       = undef,
  $ldap_search_base      = undef,
  $cert_name             = undef,
  $ldap_default_bind_uid = 'com',
  $ldap_default_authtok  = undef,
  $debug_level           = '9',
) {
  validate_array($domains)
  validate_array($filter_users)
  validate_array($filter_groups)

  case $type {

    'default': {
      $ldap_tls_cacertdir = $::osfamily ? {
        'Ubuntu' => '/etc/ssl/certs',
        'CentOS' => '/etc/openldap/cacerts',
        default  => '/etc/ssl/certs',
      }

      # Make sure certificate is there
      file { "${ldap_tls_cacertdir}/${cert_name}" :
        source => "puppet:///files/${module_name}/${cert_name}",
        owner  => 'root',
        group  => 'root',
      }

      unless $custom_template {
        $template = 'sssd/sssd_default.conf.erb'
      }

      # setup nsswitch conf
      file{ '/etc/nsswitch.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        source  => "puppet:///modules/${module_name}/etc/nsswitch.conf",
        require => Package['sssd'],
      }
      $packages = ['sssd']
      $service_deps = File["${ldap_tls_cacertdir}/${cert_name}" ]
    }

    'ad' : {
      unless $custom_template {
        $template = 'sssd/sssd.conf.erb'
      }
      $packages = ['authconfig', 'sssd']
      $service_deps = []
    }
  }

  if $custom_template {
    $template = $custom_template
  }

  package { $packages : }
    -> file { '/etc/sssd/sssd.conf':
      content => template($template),
      mode    => '0600', # must be 0600
      owner   => 'root',
      group   => 'root',
      notify  => Service['sssd']
    }
    ~> service { 'sssd':
      ensure    => running,
      enable    => true,
      subscribe => File['/etc/sssd/sssd.conf'],
      require   => $service_deps,
    }

  #if working on a RedHat based system call authconfig to setup SSSD authentication in PAM and NSS
  if ($::osfamily == 'RedHat') {
    include sssd::authconfig
  }
}
