# Load modules and classes
hiera_include('classes')

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

class { "java":
  distribution => "jre"
}

class { "nsidc_solr": }
