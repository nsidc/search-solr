# Load modules and classes
lookup('classes', {merge => unique}).include
$project = lookup('project')
$app_root = '/vagrant'
$ruby_ver = '3.4.9'
$bundler_ver = '4.0.9'
$rubygems_ver = '4.0.9'
$source_config = "/vagrant/config"
$solr_home = "/var/solr/data"
$rbenv_home = '/home/vagrant'
$rbenv_dir = "${rbenv_home}/rbenv"

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

# Install Ruby and Bundler
class { 'rbenv':
  install_dir => $rbenv_dir,
  owner       => 'vagrant',
  group       => 'vagrant',
  require     => User['vagrant'],
}
-> rbenv::plugin { 'rbenv/ruby-build': }
-> notify {'starting rbenv build': }
-> rbenv::build { $ruby_ver:
  bundler_version => $bundler_ver,
  owner => 'vagrant',
  group => 'vagrant',
  global => true,
}
-> notify {'done with rbenv build': }
-> file { "${rbenv_dir}/version":
  ensure => 'file',
  mode   => '0644',
  owner => 'vagrant',
  group => 'vagrant',
}
-> file { "${rbenv_dir}/shims/bundle":
  ensure => 'file',
  mode   => '0755',
  owner => 'vagrant',
  group => 'vagrant',
}

if ! defined (User['vagrant']) {
  @user { 'vagrant':
    ensure => present,
    groups => ['syslog', 'vagrant']
  }
} else {
  User <| title == 'vagrant' |> {
    groups => ['syslog', 'vagrant']
  }
}
realize(User['vagrant'])

unless $environment == 'ci' {
  exec { 'open port 443':
    command => 'iptables -A INPUT -p tcp --dport 443 -j ACCEPT',
    path => ['/usr/local/bin','/usr/bin', '/bin', '/usr/sbin'],
    user => 'root',
  } ->
  exec { 'open port 8983':
    command => 'iptables -A INPUT -p tcp --dport 8983 -j ACCEPT',
    path => ['/usr/local/bin','/usr/bin', '/bin', '/usr/sbin'],
    user => 'root',
  } ->
  exec { 'save port changes':
    command => 'iptables-save --file /etc/iptables/rules.v4',
    path => ['/usr/local/bin','/usr/bin', '/bin', '/usr/sbin'],
    user => 'root',
  }

  # dep for geos gems
  package {"libgeos-dev":
    ensure => present,
    require => File["${rbenv_dir}/shims/bundle"],
  }

  # install application gems
  exec { 'do_bundle_install':
    cwd     => "${app_root}",
    environment => "HOME=${app_root}",
    command => "bundle _${bundler_ver}_ install",
    path => ['/home/vagrant/rbenv/shims', '/usr/local/bin','/usr/bin', '/bin'],
    user => 'vagrant',
    group => 'vagrant',
    require => [ File["${rbenv_dir}/shims/bundle"] ]
  }

  include nginx

  exec { 'generate_certs':
    cwd     => "${app_root}/cert",
    command => 'openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout solr.key -out solr.crt -subj "/CN=nsidc"',
    path    => ['/usr/local/bin','/usr/bin','/bin'],
    user    => 'vagrant',
    group   => 'vagrant',
  }

  $nginx_hostname = $environment ? {
    'blue'       => "${project}.${domain}",
    'production' => "${project}.${domain}",
    default      => "${environment}.${project}.${domain}"
  }

  nginx::resource::vhost { $nginx_hostname:
    ensure           => present,
    cors             => true,
    server_name      => [$nginx_hostname],
    ssl              => true,
    listen_port      => 443,
    ssl_port         => 443,
    ssl_cert         => "${app_root}/cert/solr.crt",
    ssl_key          => "${app_root}/cert/solr.key",
    proxy            => 'http://localhost:8983',
    proxy_set_header => [ 'Host $host',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto https' ],
    add_header       => {
      'Access-Control-Allow-Origin'  => '*',
      'Access-Control-Allow-Methods' => 'OPTIONS,HEAD,GET,PUT,POST,DELETE',
      'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept, Range'
    },
    proxy_read_timeout => '180',
    require => [ Exec['generate_certs'] ]
  }

  class { "nsidc_solr":
    jetty_host => '0.0.0.0'
  }

  file_line { "solr_modules":
    ensure => present,
    line   => "SOLR_MODULES=scripting",
    path   => "/etc/environment"
  }

  # This is a workaround, as for some reason when we SSH into the VM, the locale language
  # is not being set properly.  Mike Laxer and Scott Lewis were both unable to figure out
  # the cause, as other projects don't seem to be having this issue, and the VM template
  # does have the proper setup to do this.  If the root cause for this issue can be found
  # this command could be removed, but this at least addresses the issue to allow the
  # acceptance tests to work (primarily the one testing accents)
  file { "locale-lang-fix":
    ensure => present,
    path   => "/etc/profile.d/locale-lang-fix.sh",
    content => "export LANG=en_US.UTF-8"
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

  # Create the log file that can be used (as vagrant doesn't normally have permission)
  file { '/var/log/search-solr-tools.log':
    ensure => present,
    group  => vagrant,
    mode   => '0664'
  }
}
