# Load modules and classes
lookup('classes', {merge => unique}).include

# $project = lookup('project')
# $app_root = "/opt/${project}"
$app_root = '/vagrant'
# $source_dir = "/vagrant"
$ruby_ver = '2.6.6' # '3.2.2'
$bundler_ver = '2.1.4' # '2.4.10'
$rubygems_ver = '3.3.21' # 3.4.10'
$source_config = "/vagrant/config"
$solr_home = "/var/solr/data"

# If the structure of the Solr COTS tar file changes, the path to the default
# configuration and mapping file(s) will need to change as well.
$solr_default_path = "/opt/solr/server/solr/configsets/_default"
$example_iso_mappings = "/opt/solr/server/solr/configsets/sample_techproducts_configs/conf/mapping-ISOLatin1Accent.txt"

### BEGIN nokogiri deps
package {"libssl-dev":
  ensure => present
} ->
package {"build-essential":
  ensure => present
} ->
### END nokogiri deps

class { 'rbenv':
  install_dir => '/home/vagrant/rbenv',
  owner => 'vagrant',
  group => 'vagrant',
}
-> exec { 'rbenv-build-prepare-git':
  command => 'git config --global --add safe.directory /home/vagrant/rbenv/plugins/ruby-build',
  path => ['/usr/local/bin', '/usr/bin', '/bin'],
  environment => ['HOME=/home/vagrant'],
}
-> rbenv::plugin { 'rbenv/ruby-build': }
-> rbenv::build { $ruby_ver:
  bundler_version => $bundler_ver,
  owner => 'vagrant',
  group => 'vagrant',
  global => true,
}
-> rbenv::gem { 'builder': ruby_version => $ruby_ver }
-> exec { 'gem_update':
  command => "gem update --system ${rubygems_ver}",
  path    => ['/home/vagrant/rbenv/shims', '/usr/local/bin','/usr/bin', '/bin'],
}

unless $environment == 'ci' {
  # dep for geos gems
  package {"libgeos-dev":
    ensure => present,
    require => Exec['gem_update']
  }

  # install application gems
  exec { 'do_bundle_install':
    cwd     => "${app_root}",
    environment => "HOME=${app_root}",
    command => "bundle _${bundler_ver}_ install",
    path => ['/home/vagrant/rbenv/shims', '/usr/local/bin','/usr/bin', '/bin'],
    user => 'vagrant',
    group => 'vagrant',
    require => [ Exec['gem_update'] ]
  }

  class { "nsidc_solr":
    jetty_host => '0.0.0.0'
  }

  file_line { "solr_modules":
    ensure => present,
    line   => "SOLR_MODULES=scripting",
    path   => "/etc/environment"
  }

  file { "init-solr-auto-suggest":
    path => "${solr_home}/auto_suggest",
    ensure => directory,
    recurse => true,
    owner   => solr,
    group   => solr,
    source => $solr_default_path,
    require => Exec['deploy-solr'],
    notify  => Service["solr"]
  }

  file { "customize-solr-auto-suggest":
    path => "${solr_home}/auto_suggest/core.properties",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "${source_config}/auto_suggest/core.properties",
    require => File['init-solr-auto-suggest'],
    notify  => Service['solr']
  }

  file { "customize-solr-auto-suggest-schema":
    path    => "${solr_home}/auto_suggest/conf/managed-schema",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "${source_config}/auto_suggest/conf/managed-schema",
    require => File['customize-solr-auto-suggest'],
    notify  => Service['solr']
  }

  file { "init-solr-nsidc-oai":
    path => "${solr_home}/nsidc_oai",
    ensure => directory,
    recurse => true,
    owner   => solr,
    group   => solr,
    source => $solr_default_path,
    require => Exec['deploy-solr'],
    notify  => Service["solr"]
  }

  file { "customize-solr-nsidc-oai":
    path => "${solr_home}/nsidc_oai/core.properties",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "${source_config}/nsidc_oai/core.properties",
    require => File['init-solr-nsidc-oai'],
    notify  => Service['solr']
  }

  file { "customize-solr-nsidc-oai-schema":
    path    => "${solr_home}/nsidc_oai/conf/managed-schema",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "${source_config}/nsidc_oai/conf/managed-schema",
    require => File['customize-solr-nsidc-oai'],
    notify  => Service['solr']
  }

  $iso_mappings =  [ "${solr_home}/nsidc_oai/conf/mapping-ISOLatin1Accent.txt",
                     "${solr_home}/auto_suggest/conf/mapping-ISOLatin1Accent.txt" ]
  file { $iso_mappings:
    ensure  => file,
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source => $example_iso_mappings,
    require => [ File['customize-solr-auto-suggest'], File['customize-solr-nsidc-oai'] ],
    notify  => Service['solr']
  }

  $elevate =  [ "${solr_home}/nsidc_oai/conf/elevate.xml",
                "${solr_home}/auto_suggest/conf/elevate.xml" ]
  file { $elevate:
    ensure  => file,
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "${source_config}/elevate.xml",
    require => [ File['customize-solr-auto-suggest'], File['customize-solr-nsidc-oai'] ],
    notify  => Service['solr']
  }

  $solrconfigs =  [ "${solr_home}/nsidc_oai/conf/solrconfig.xml",
                    "${solr_home}/auto_suggest/conf/solrconfig.xml" ]
  file { $solrconfigs:
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "${source_config}/solrconfig.xml",
    require => [ File['customize-solr-auto-suggest'], File['customize-solr-nsidc-oai'] ],
    notify  => Service['solr']
  }

  # Work directory will prevent solr from writing to /tmp
  file { "${solr_home}/work":
    ensure => "directory",
    owner   => solr,
    group   => solr,
    notify  => Service["solr"]
  }
}
