# Class: dnsdist
#
# This class installs and manages dnsdist
#
# Author
#   Michiel Piscaer <michiel@piscaer.com>
#
# Version
#   0.1   Initial release
#
# Parameters:
#   @param version
#   @param webserver_enabled
#   @param webserver = '0.0.0.0:80'
#   @param webserver_pass = 'geheim'
#   @param console_enabled
#   @param control_socket = '127.0.0.1'
#   @param console_key
#   @param listen_addresses = '0.0.0.0'
#   @param listen_port
#   @param tls_enabled
#   @param tls_port
#   @param tls_key
#   @param tls_cert
#   @param doh_enabled
#   @param doh_key
#   @param doh_cert
#   @param cache_enabled
#   @param cache_size
#   @param metrics_enabled
#   @param metrics_host
#
# Requires:
#   concat
#   apt
#
# Sample Usage:
#
#   class { 'dnsdist':
#    webserver        => '192.168.1.1:80',
#    listen_addresses => [ '192.168.1.1' ];
#  }
#
class dnsdist (
  String $version,
  Optional[Boolean] $webserver_enabled = undef,
  Optional[String] $webserver          = undef,
  Optional[String] $webserver_pass     = undef,
  Boolean $console_enabled,
  String $control_socket,
  String $console_key,
  Array $listen_addresses,
  Integer $listen_port,
  Optional[Boolean] $tls_enabled       = undef,
  Optional[Integer] $tls_port          = undef,
  String $tls_key,
  String $tls_cert,
  Optional[Boolean] $doh_enabled       = undef,
  String $doh_key,
  String $doh_cert,
  Optional[Boolean] $cache_enabled     = undef,
  Optional[Integer] $cache_size        = undef,
  Optional[Boolean] $metrics_enabled   = undef,
  Optional[String] $metrics_host       = undef,
) {
  apt::pin { 'dnsdist':
    origin   => 'repo.powerdns.com',
    priority => '600',
  }

  apt::source { 'repo.powerdns.com':
    location     => 'http://repo.powerdns.com/ubuntu',
    repos        => 'main',
    release      => join([$facts['os']['distro']['codename'], '-dnsdist-', $version], ''),
    architecture => 'amd64',
    key          => {
      id     => '9FAAA5577E8FCF62093D036C1B0C6205FD380FBB',
      server => 'keyserver.ubuntu.com',
    },
    require      => [Apt::Pin['dnsdist']];
  }

  package { 'dnsdist':
    ensure  => present,
    require => [Apt::Source['repo.powerdns.com']];
  }

  $_group = if versioncmp($version, '1.4') == 1 {
    '_dnsdist'
  } else {
    'root'
  }

  concat { '/etc/dnsdist/dnsdist.conf' :
    owner   => 'root',
    group   => $_group,
    mode    => '0644',
    notify  => Service['dnsdist'],
    require => [Package['dnsdist']],
  }

  concat::fragment { 'global-header':
    target  => '/etc/dnsdist/dnsdist.conf',
    content => template('dnsdist/concat_fragments/dnsdist.conf-header.erb'),
    order   => '10',
  }

  concat::fragment { 'acl-header':
    target  => '/etc/dnsdist/dnsdist.conf',
    content => 'setACL({',
    order   => '40',
  }

  concat::fragment { 'acl-footer':
    target  => '/etc/dnsdist/dnsdist.conf',
    content => "})\n",
    order   => '49',
  }

  service { 'dnsdist':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [Concat['/etc/dnsdist/dnsdist.conf']],
  }

  $dnsdist_acl = lookup('dnsdist::acl', Hash, 'deep', {})
  $dnsdist_acl_defaults = {}
  create_resources(dnsdist::acl, $dnsdist_acl, $dnsdist_acl_defaults)

  $dnsdist_newserver = lookup('dnsdist::newserver', Hash, 'deep', {})
  $dnsdist_newserver_defaults = {}
  create_resources(dnsdist::newserver, $dnsdist_newserver, $dnsdist_newserver_defaults)

  $dnsdist_addaction = lookup('dnsdist::addaction', Hash, 'deep', {})
  $dnsdist_addaction_defaults = {}
  create_resources(dnsdist::addaction, $dnsdist_addaction, $dnsdist_addaction_defaults)

  $dnsdist_addpoolrule = lookup('dnsdist::addpoolrule', Hash, 'deep', {})
  $dnsdist_addpoolrule_defaults = {}
  create_resources(dnsdist::addpoolrule, $dnsdist_addpoolrule, $dnsdist_addpoolrule_defaults)
}

