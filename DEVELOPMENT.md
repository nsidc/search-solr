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

* Ruby (>=3.2.2) with development headers (ruby-dev/ruby-devel)
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

  *Please note*:  If you are having difficulty installing Nokogiri please review
  the Nokogiri [installation tutorial](http://www.nokogiri.org/tutorials/installing_nokogiri.html)

* An installed instance of [Solr 9.3.0](https://lucene.apache.org/solr/guide/)

## NSIDC

Option 1: Provision in vSphere
```shell
vagrant nsidc up --env=dev
```

The Solr dashboard for the dev environment is accessible from
[http://dev.search-solr.apps.int.nsidc.org:8983/solr]().

### Working with Solr on the VM

You may want to work as the `solr` user on the command line when investigating
files on the VM:
```
sudo su solr
```

To get a status report for the local solr instance:

```
${solr_install_dir}/bin/solr/status
```

On NSIDC VMs, `${solr_install_dir}` is `opt/solr`.

Option 2: Provision in VirtualBox
```shell
vagrant nsidc up --env=local
```

The Solr dashboard for the local environment is accessible from
[http://localhost:8983/solr]().

## Non-NSIDC

As much as possible, the installation and configuration of Solr for this project
follows the defaults of the Solr package. Customizations to the Solr defaults
are in the [config](config/) directory in this repository.  Refer to the 
[Solr documentation](https://lucene.apache.org/solr/resources.html) for additional
installation and configuration guidelines.
