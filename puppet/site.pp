# Load modules and classes
lookup('classes', {merge => unique}).include

$config_path = "/vagrant/config"
$solr_default_path = "/opt/solr/server/solr/configsets/_default"
$solr_home = "/var/solr/data"
$solr_tools_path = "/opt/search-solr-tools"

# If the structure of the Solr COTS tar file changes, the path to the default
# version of solrconfig.xml may need to change too!
$solrconfig_xml_path = "/opt/solr/server/solr/configsets/_default/conf/solrconfig.xml"
$example_iso_mappings = "/opt/solr/server/solr/configsets/sample_techproducts_configs/conf/mapping-ISOLatin1Accent.txt"

# class update_package_manager {
#   exec { "update":
#     path => "/bin:/usr/bin:/usr/local/bin:/usr/local/sbin:usr/sbin:/sbin:/usr/java/jdk/bin",
#     command => "apt-get -y update; sudo apt-get -y install libxml2 libxml2-dev libxslt1-dev"
#   }
#   notify { "apt-get update complete":
#     require => Exec['update']
#   }
# }

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

package { 'ruby-switch':
  ensure => present,
} ->
package { 'ruby2.5':
  ensure => present,
  require => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
} ->
package { 'ruby2.5-dev':
  ensure => present,
  require => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
} ->

exec { 'set ruby':
  command => 'ruby-switch --set ruby2.5',
  path => ['/usr/bin'],
  require => Package['ruby-switch']
} ->

package { 'bundler':
  provider => 'gem',
  ensure   => 'installed',
}

# update rubygems and install application gems
exec { 'install rubygems update':
  command => 'gem install rubygems-update',
  path    => ['/usr/local/bin','/usr/bin', '/bin'],
  user    => 'root',
  group   => 'root',
  require => [ Package['bundler'] ]
} ->
 
exec { 'update rubygems':
  command => 'update_rubygems',
  path    => ['/usr/local/bin','/usr/bin', '/bin'],
  user    => 'root',
  group   => 'root'
} ->

exec { 'gem update':
  command => 'gem update --system',
  path    => ['/usr/local/bin','/usr/bin', '/bin'],
  user    => 'root',
  group   => 'root'
}

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
    require => Package['bundler']
  }

  # install application gems
  exec { 'do_bundle_install':
    cwd => '/vagrant',
    environment => 'HOME=/vagrant',
    command => 'bundle install',
    path => ['/usr/local/bin', '/usr/bin', '/bin'],
    user => 'vagrant',
    group => 'vagrant',
    require => [ Package['bundler'] ]
  }

  # nokogiri 'build native' dep
  package { 'zlib1g-dev':
    ensure => present,
    require => Package['bundler']
  }

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
    source  => "/vagrant/config/auto_suggest/core.properties",
    require => File['init-solr-auto-suggest'],
    notify  => Service['solr']
  }

  file { "customize-solr-auto-suggest-solrconfig":
    path    => "${solr_home}/auto_suggest/conf/solrconfig.xml",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/auto_suggest/conf/solrconfig.xml",
    require => File['customize-solr-auto-suggest'],
    notify  => Service['solr']
  }

  file { "customize-solr-auto-suggest-schema":
    path    => "${solr_home}/auto_suggest/conf/managed-schema",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/auto_suggest/conf/managed-schema",
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
    source  => "/vagrant/config/nsidc_oai/core.properties",
    require => File['init-solr-nsidc-oai'],
    notify  => Service['solr']
  }

  file { "customize-solr-nsidc-oai-solrconfig":
    path    => "${solr_home}/nsidc_oai/conf/solrconfig.xml",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/nsidc_oai/conf/solrconfig.xml",
    require => File['customize-solr-nsidc-oai'],
    notify  => Service['solr']
  }

  file { "customize-solr-nsidc-oai-schema":
    path    => "${solr_home}/nsidc_oai/conf/managed-schema",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/nsidc_oai/conf/managed-schema",
    require => File['customize-solr-nsidc-oai'],
    notify  => Service['solr']
  }

  $mappings =  ["${solr_home}/nsidc_oai/conf/mapping-ISOLatin1Accent.txt",
                "${solr_home}/auto_suggest/conf/mapping-ISOLatin1Accent.txt"]

  file { $mappings:
    ensure  => file,
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source => $example_iso_mappings,
    require => File['customize-solr-nsidc-oai'],
    notify  => Service['solr']
  }

  # Work directory will prevent solr from writing to /tmp
  file { "${solr_home}/work":
    ensure => "directory",
    owner   => solr,
    group   => solr,
    notify  => Service["solr"]
  }

  file { "${solr_tools_path}":
    ensure => "directory"
  }
}
