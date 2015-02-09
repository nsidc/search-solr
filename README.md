# nsidc-search-solr

This vagrant project stands up a Solr instance for NSIDC Search / Arctic Data
Explorer.

NOTE: this README is up to date with the master branch, meaning it may contain
information for an unreleased version of **puppet-nsidc-solr**. For details on what
may have changed since the version you are using, see the
[Changelog](https://bitbucket.org/nsidc/puppet-nsidc-solr/src/master/CHANGELOG.md). For
past versions of the README, see:

* [v0.1.0](https://bitbucket.org/nsidc/vagrant-nsidc-plugin/src/v0.1.0/?at=v0.1.0)


# Requirements

This project requires the
[vagrant-nsidc-plugin](https://bitbucket.org/nsidc/vagrant-nsidc-plugin).

# Setup

The virtual machine will be provisioned using the
[puppet-nsidc-solr](https://bitbucket.org/nsidc/puppet-nsidc-solr) module.
NSIDC Search / Arctic Data Explorer configurations will be applied once Solr is
installed.

To provision the machine:
```shell
vagrant nsidc up --env=dev
```

Once provisioning is complete, the Solr dashboard is accessible from
[http://<environment>.search-solr.apps.int.nsidc.org:9283/solr](), where
<environment> is one of dev, integration, qa, etc.

## Development

Instructions and notes for developing this project are in
[DEVELOPMENT](https://bitbucket.org/nsidc/puppet-nsidc-solr/src/master/DEVELOPMENT.md).
