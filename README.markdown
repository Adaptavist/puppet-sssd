# SSSD
[![Build Status](https://travis-ci.org/Adaptavist/puppet-sssd.svg?branch=master)](https://travis-ci.org/Adaptavist/puppet-sssd)

Install and configure SSSD to authenticate users via PAM and NSS with an active directory server.

## Usage

Include sssd class in your hiera config and adjust following parmeters

## Parameters 

* type                  - type of ldap server, supported options are 'default' and 'ad' active directory
* domains               - Define domain lookup order for sssd, ['ldap://example0.company.com/', 'ldap://example1.company.com'],
* filter_users          - Filter to exclude users from sssd lookups. [ 'root' ]
* filter_groups         - Filter to exclude groups from sssd lookups. [ 'root' ]
* custom_template       - Used to specify an alternate template instead of the one used by the module.
* ldap_search_base      - Default ldap params passed to sssd.conf e.g. 'dc=company,dc=com'
* cert_name             - certificate must be present in files/sssd/${cert_name} of your puppetmaster e.g. 'company-cacert.pem'
* ldap_default_bind_uid - Bind uid, default is company_service_unix_ldap
* ldap_default_authtok  - Default ldap params passed to sssd.conf, default set to company_authtok
* debug_level           - Debug level, default set to 9

See init.pp for more details.

## Usage

```
sssd::type: 'default'
sssd::domains:
  - 'ldap://example0.company.com'
  - 'ldap://example1.company.com'
sssd::filter_users:
  - 'root'
sssd::filter_groups:
  - 'root'
sssd::custom_template: "path_to_custom_template"
sssd::ldap_search_base: 'dc=company,dc=com'
sssd::cert_name: 'company-cacert.pem'
sssd::ldap_default_bind_uid: 'company_service_unix_ldap'
sssd::ldap_default_authtok: 'company_authtok'

```

## Documentation

[SSSD project](https://fedorahosted.org/sssd/)
[SSSD user guide](http://docs.fedoraproject.org/en-US/Fedora/14/html/Deployment_Guide/chap-SSSD_User_Guide-Introduction.html)
