# Load modules and classes
lookup('classes', {merge => unique}).include

class { '::java':
  distribution => 'jre'
}

$solr_path = "/opt/solr"
$solr_tools_path = "/opt/search-solr-tools"

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
    ensure => present
  }

  # nokogiri 'build native' dep
  package { 'zlib1g-dev':
    ensure => present,
    require => Package['bundler']
  }

  class { "nsidc_solr": }

  $collection_dirs = [
                       "${solr_path}/nsidc_oai",
                       "${solr_path}/nsidc_oai/conf",
                       "${solr_path}/nsidc_oai/data",
                       "${solr_path}/auto_suggest",
                       "${solr_path}/auto_suggest/conf",
                       "${solr_path}/auto_suggest/data"
                     ]

  file { $collection_dirs:
    ensure  => 'directory',
    recurse => true,
    purge   => true,
    owner   => solr,
    group   => solr,
    require => Exec['deploy-solr'],
    notify  => Service['solr']
  }

  exec { "setup-solr-auto-suggest-collection":
    command => "/usr/bin/sudo ls ${solr_path}/nsidc_oai",
    cwd     => "$solr_path",
    require => File[$collection_dirs],
    notify  => Service["solr"]
  }

  exec { "setup-solr-collection":
    command => "/usr/bin/sudo ls ${solr_path}/auto_suggest",
    cwd     => "$solr_path",
    require => Exec["setup-solr-auto-suggest-collection"],
    notify  => Service["solr"]
  }

  notify { 'done with step':
    message => 'setup-solr-collection complete',
    require => Exec["setup-solr-collection"]
  }

  file { "solr-xml":
    path    => "${solr_path}/solr.xml",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/solr.xml",
    require => Exec['setup-solr-collection'],
    notify  => Service['solr']
  }

  file { 'solr-config':
    path    => "${solr_path}/nsidc_oai/conf/solrconfig.xml",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => '/vagrant/config/solrconfig.nsidc_oai.xml',
    require => File['solr-xml'],
    notify  => Service['solr']
  }

  file { 'solr-auto-suggest-config':
    path    => "${solr_path}/auto_suggest/conf/solrconfig.xml",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => '/vagrant/config/solrconfig.autosuggest.xml',
    require => File['solr-config'],
    notify  => Service['solr']
  }

  file { 'solr-schema-config':
    path    => "${solr_path}/nsidc_oai/conf/schema.xml",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/schema.xml",
    require => File["solr-auto-suggest-config"],
    notify  => Service["solr"]
  }

  file { 'solr-schema-auto-suggest-config':
    path    => "${solr_path}/auto_suggest/conf/schema.xml",
    mode    => '0644',
    owner   => solr,
    group   => solr,
    source  => '/vagrant/config/schema.autosuggest.xml',
    require => File['solr-schema-config'],
    notify  => Service['solr']
  }

  # Work directory will prevent solr from writing to /tmp
  file { "${solr_path}/work":
    ensure => "directory",
    owner   => solr,
    group   => solr,
    notify  => Service["solr"]
  }

  file { "${solr_tools_path}":
    ensure => "directory"
  }
}
