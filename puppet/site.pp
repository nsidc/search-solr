# Load modules and classes
lookup('classes', {merge => unique}).include

$source_config = "/vagrant/config"
$solr_home = "/var/solr/data"

# If the structure of the Solr COTS tar file changes, the path to the default
# configuration and mapping file(s) will need to change as well.
$solr_default_path = "/opt/solr/server/solr/configsets/_default"
$example_iso_mappings = "/opt/solr/server/solr/configsets/sample_techproducts_configs/conf/mapping-ISOLatin1Accent.txt"

### BEGIN nokogiri deps
# Class['update_package_manager'] -> Package <| |>

package {"libssl-dev":
  ensure => present
} ->
package {"build-essential":
  ensure => present
} ->
# include update_package_manager
### END nokogiri deps

apt::ppa{'ppa:brightbox/ruby-ng':}

# Install Ruby, Bundler, and Builder
# Builder is required to do `gem generate_index`
class { 'rbenv': }
-> rbenv::plugin { 'rbenv/ruby-build': }
-> rbenv::build { '2.6.5':
  bundler_version => '2.2.17',
  global => true,
}
-> rbenv::gem { 'builder': ruby_version => '2.6.5' }
-> exec { 'gem_update':
  command => 'gem update --system',
  path    => ['/usr/local/rbenv/shims', '/usr/local/bin','/usr/bin', '/bin'],
  user    => 'root',
  group   => 'root'
}


# package { 'ruby-switch':
#   ensure => present,
# } ->
# package { 'ruby2.6':
#   ensure => present,
#   require => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
# } ->
# package { 'ruby2.6-dev':
#   ensure => present,
#   require => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
# } ->
#
# exec { 'set ruby':
#   command => 'ruby-switch --set ruby2.6',
#   path => ['/usr/bin'],
#   require => Package['ruby-switch']
# } ->
#
# exec { 'bundler':
#   command => 'gem install bundler',
#   path => ['/usr/bin']
# } ->
#
# # update rubygems and install application gems
# exec { 'install rubygems update':
#   command => 'gem install rubygems-update',
#   path    => ['/usr/local/bin','/usr/bin', '/bin'],
#   user    => 'root',
#   group   => 'root',
#   require => [ Exec['bundler'] ]
# } ->
#
# exec { 'update rubygems':
#   command => 'update_rubygems',
#   path    => ['/usr/local/bin','/usr/bin', '/bin'],
#   user    => 'root',
#   group   => 'root'
# } ->
#
# exec { 'gem update':
#   command => 'gem update --system',
#   path    => ['/usr/local/bin','/usr/bin', '/bin'],
#   user    => 'root',
#   group   => 'root'
# }

if $environment == 'ci' {
  package { 'rake':
    provider => 'gem',
    ensure   => 'installed'
  }
}

unless $environment == 'ci' {
  # dep for geos gems
  package {"libgeos-dev":
    ensure => present,
    # require => Exec['bundler']
    require => Exec['gem_update']
  }

  # install application gems
  exec { 'do_bundle_install':
    cwd => '/vagrant',
    environment => 'HOME=/vagrant',
    command => 'bundle install',
    path => ['/usr/local/rbenv/shims', '/usr/local/bin', '/usr/bin', '/bin'],
    user => 'vagrant',
    group => 'vagrant',
    # require => Exec['bundler'],
    require => Exec['gem_update']
  }

  # # nokogiri 'build native' dep
  # package { 'zlib1g-dev':
  #   ensure => present,
  #   require => Exec['bundler']
  # }

  class { "nsidc_solr": }

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
