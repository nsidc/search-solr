## Contributing

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Stage your changes (`git add`)
3. Commit your puppet-lint(http://puppet-lint.com/) compliant and test-passing changes with a
   [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
  (`git commit`)
4. Push to the branch (`git push -u origin my-new-feature`)
5. Create a new Pull Request

# Startup

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

# Solr Configuration Files

Solr is configured using XML files. Cores are defined in `config/solr.xml`.
The Solr cores each require a schema file and a Solr configuration file.
All configuration files are found under `config/`.

