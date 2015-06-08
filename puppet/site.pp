# Load modules and classes
hiera_include('classes')

$solr_path = "/opt/solr"
$solr_tools_path = "/opt/search-solr-tools"

class update-package-manager {
  exec { "update":
    path => "/bin:/usr/bin:/usr/local/bin:/usr/local/sbin:usr/sbin:/sbin:/usr/java/jdk/bin",
    command => "apt-get -y update; sudo apt-get -y install libxml2 libxml2-dev libxslt1-dev"
  }
  notify { "apt-get update complete":
    require => Exec['update']
  }
}

### BEGIN nokogiri deps
Class['update-package-manager'] -> Package <| |>

package {"libssl-dev":
  ensure => present
} ->
package {"build-essential":
  ensure => present
} ->
package {"libxml2-dev":
  ensure => present
}

include update-package-manager
### END nokogiri deps

# If using bumpversion (python) for your version bumping
# needs, you can uncomment this to get bumpversion and
# fabric (python task runner)
if $environment == 'ci' {
  class { 'python':
    version => 'system',
    pip     => true,
    dev     => true # Needed for fabric
  }

  python::pip { 'bumpversion':
    pkgname => 'bumpversion',
    ensure  => '0.5',
    owner   => 'root'
  }

  # Task runner for python
  python::pip { 'fabric':
    pkgname => 'fabric',
    ensure  => '1.10',
    owner   => 'root'
  }

  package { 'rake':
    provider => 'gem',
    ensure   => 'installed'
  }
  package { 'bundler':
    provider => 'gem'
  }
}

if ($environment == 'local') or ($environment == 'dev') or ($environment == 'integration') or ($environment == 'qa') or ($environment == 'staging') or ($environment == 'production') or ($environment == 'blue') or ($environment == 'green') or ($environment == 'red') {
  # Ensure the brightbox apt repository gets added before installing ruby
  include apt
  apt::ppa{'ppa:brightbox/ruby-ng':}

  package { 'ruby2.2':
    ensure => present,
    require => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
  } ->
  package { 'ruby2.2-dev':
    ensure => present
  } ->
  exec { 'install bundler':
    command => 'sudo gem install bundler -v 1.10.3',
    path => '/usr/bin'
  }->

  # nokogiri 'build native' dep
  package { 'zlib1g-dev':
    ensure => present
  }

  class { "nsidc_solr": }

  # Configure Solr with NSIDC/ADE Search cores
  file { "${solr_path}/solr/nsidc_oai":
    ensure  => "absent",
    force   => true,
    alias   => "nsidc_oai-removed",
    require => Exec["deploy-solr"],
    notify  => Service["solr"]
  }

  file { "${solr_path}/solr/auto_suggest":
    ensure  => "absent",
    force   => true,
    alias   => "autosuggest-removed",
    require => File["nsidc_oai-removed"],
    notify  => Service["solr"]
  }

  exec { "setup-solr-auto-suggest-collection":
    command => "/usr/bin/sudo /bin/cp -r ${solr_path}/solr/collection1 ${solr_path}/solr/nsidc_oai",
    cwd     => "$solr_path",
    require => File["autosuggest-removed"],
    notify  => Service["solr"]
  }

  exec { "setup-solr-collection":
    command => "/usr/bin/sudo /bin/mv ${solr_path}/solr/collection1 ${solr_path}/solr/auto_suggest",
    cwd     => "$solr_path",
    require => Exec["setup-solr-auto-suggest-collection"],
    notify  => Service["solr"]
  }

  notify { 'done with step':
    message => 'setup-solr-collection complete',
    require => Exec["setup-solr-collection"]
  }

  file { "${solr_path}/solr/solr.xml":
    mode    => 0644,
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/solr.xml",
    alias   => "solr-xml",
    require => Exec["setup-solr-collection"],
    notify  => Service["solr"]
  }

  file { "${solr_path}/solr/nsidc_oai/conf/solrconfig.xml":
    mode    => 0644,
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/solrconfig.nsidc_oai.xml",
    alias   => "solr-config",
    require => File["solr-xml"],
    notify  => Service["solr"]
  }

  file { "${solr_path}/solr/auto_suggest/conf/solrconfig.xml":
    mode    => 0644,
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/solrconfig.autosuggest.xml",
    alias   => "solr-auto-suggest-config",
    require => File["solr-config"],
    notify  => Service["solr"]
  }

  file { "${solr_path}/solr/nsidc_oai/conf/schema.xml":
    mode    => 0644,
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/schema.xml",
    alias   => "solr-schema-config",
    require => File["solr-auto-suggest-config"],
    notify  => Service["solr"]
  }

  file { "${solr_path}/solr/auto_suggest/conf/schema.xml":
    mode    => 0644,
    owner   => solr,
    group   => solr,
    source  => "/vagrant/config/schema.autosuggest.xml",
    alias   => "solr-schema-auto-suggest-config",
    require => File["solr-schema-config"],
    notify  => Service["solr"]
  }

  # Create data and tlog directories so Solr can write to them
  file { "${solr_path}/solr/nsidc_oai/data":
    ensure => "directory",
    owner   => solr,
    group   => solr
  }

  file { "${solr_path}/solr/nsidc_oai/data/tlog":
    ensure => "directory",
    owner   => solr,
    group   => solr
  }

  file { "${solr_path}/solr/auto_suggest/data":
    ensure => "directory",
    owner   => solr,
    group   => solr
  }

  file { "${solr_path}/solr/auto_suggest/data/tlog":
    ensure => "directory",
    owner   => solr,
    group   => solr
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
