## Contributing

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Stage your changes (`git add`)
3. Commit your puppet-lint(http://puppet-lint.com/) compliant and test-passing changes with a
   [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
  (`git commit`)
4. Push to the branch (`git push -u origin my-new-feature`)
5. Create a new Pull Request

# Development environment

Please note that successful passing acceptance tests require a harvest of data from
[search-solr-tools](https://github.com/nsidc/search-solr-tools).

## Requirements

Ruby environment for acceptance testing:

* Ruby (>2.0.0) with development headers (ruby-dev/ruby-devel)
* [Bundler](http://bundler.io/)
* gcc or another compiler
* All gems listed in the Gemspec
* Nokogiri (and the following requirements):
  * [libxml2/libxml2-dev](http://xmlsoft.org/)
  * [zlibc](http://www.zlibc.linux.lu/)
  * [zlib1g/zlib1g-dev](http://zlib.net/)
  * Dependency build requirements:
    * For Ubuntu/Debian, install the build-essential package.
    * On the latest Fedora release installing the following will get you all of the requirements:
          `yum groupinstall 'Development Tools'`

          `yum install gcc-c++`

  *Please note*:  If you are having difficulty installing Nokogiri please review the Nokogiri [installation tutorial](http://www.nokogiri.org/tutorials/installing_nokogiri.html)

* [Solr 4.3.0](https://archive.apache.org/dist/lucene/solr/4.3.0/) installed
* All [requirements](https://lucene.apache.org/solr/4_3_0/SYSTEM_REQUIREMENTS.html) for Solr 4.3.0

## NSIDC

Option 1: Provision in vSphere
```shell
vagrant nsidc up --env=dev
```

The Solr dashboard for the dev environment is accessible from
[http://dev.search-solr.apps.int.nsidc.org:8983/solr]()

Option 2: Provision in VirtualBox
```shell
vagrant nsidc up --env=local
```

The Solr dashboard for the local environment is accessible from
[http://localhost:8983/solr]()

## Non-NSIDC

Install the development requirements, then configure SOLR as noted in
[`README.md`](https://github.com/nsidc/nsidc-solr/blob/master/README.md).

# Solr Configuration Files

Solr is configured using XML files. Cores are defined in `config/solr.xml`.
The Solr cores each require a schema file and a Solr configuration file.
All configuration files are found under `config/`.
