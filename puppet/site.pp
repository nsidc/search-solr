# Load modules and classes
hiera_include('classes')

$solr_path = "/opt/solr"

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
}

if (($environment == 'local') or $environment == 'dev') or ($environment == 'integration') or ($environment == 'qa') or ($environment == 'staging') or ($environment == 'production') or ($environment == 'blue') or ($environment == 'green') or ($environment == 'red') {
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
}
