# nsidc-search-solr

This vagrant project stands up a Solr instance for NSIDC Search / Arctic Data
Explorer.

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
