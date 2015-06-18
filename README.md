# nsidc-search-solr

This vagrant project stands up a Solr instance for NSIDC Search / Arctic Data
Explorer.

See
[CHANGELOG.md](https://bitbucket.org/nsidc/search-solr/src/master/CHANGELOG.md)
for information on past versions.

# Requirements

## NSIDC
For use at NSIDC, this project requires the [vagrant-nsidc-plugin](https://bitbucket.org/nsidc/vagrant-nsidc-plugin).

Dependencies are defined in the CI configuration and should be available upon machine provision.

## Non-NSIDC
When using the project outside of the NSIDC environment, the configuration that would normally
be applied via the configuration in puppet/* will not be applied, and solr will
not be setup to run.

To use this project you will have to set up an environment with the following
requirements met:

* [Solr 4.3.0](https://archive.apache.org/dist/lucene/solr/4.3.0/) installed
* All [requirements](https://lucene.apache.org/solr/4_3_0/SYSTEM_REQUIREMENTS.html) for Solr 4.3.0

# Setup

## NSIDC
The virtual machine will be provisioned using the
[puppet-nsidc-solr](https://bitbucket.org/nsidc/puppet-nsidc-solr) module.
NSIDC Search / Arctic Data Explorer configurations will be applied once Solr is
installed.

To provision the machine:
```shell
vagrant nsidc up --env=dev
```

Once provisioning is complete, the Solr dashboard is accessible from
[http://<environment>.search-solr.apps.int.nsidc.org:8983/solr](), where
<environment> is one of dev, integration, qa, etc.

Additionally if the VM is brought up via the CI jenkins job (as defined in ci.yaml)
[ search-solr-tools](https://bitbucket.org/nsidc/search-solr-tools) will be deployed
 and available on the newly-provisioned machine.  

## Non-NSIDC

Solr by default comes with a configured jetty out of the box.   You can run a local
SOLR instance by running:

   `solr start -e cloud -noprompt`

(see https://lucene.apache.org/solr/quickstart.html).

To configure solr to use NSIDC's schema.xml and other configurations, move the
files in config/* to the location (modified for your environment) listed in the
puppet/site.pp

## Development

Instructions and notes for developing this project are in
[DEVELOPMENT](https://bitbucket.org/nsidc/puppet-nsidc-solr/src/master/DEVELOPMENT.md).
