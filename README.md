# nsidc-search-solr

This vagrant project stands up a Solr instance for NSIDC Search / Arctic Data
Explorer.

See
[CHANGELOG.md](https://github.com/nsidc/search-solr/blob/master/CHANGELOG.md)
for information on past versions.

# Requirements and Setup at NSIDC

## Requirements
For use at NSIDC, this project requires the [vagrant-nsidc-plugin](https://bitbucket.org/nsidc/vagrant-nsidc-plugin).

Dependencies are defined in the CI configuration and should be available upon machine provision.

Note that the `search-solr-tools` gem is **not** installed via Bundler.
See the entries matching the strings `deploy_solr_tools_command` and
`Deploy_solr-search-tools-gem` in `puppet/ci.yaml`.

## Setup
The virtual machine will be provisioned using the
[puppet-nsidc-solr](https://bitbucket.org/nsidc/puppet-nsidc-solr) module.
NSIDC Search / Arctic Data Explorer configurations will be applied once Solr is
installed.

To provision the machine:
```shell
vagrant nsidc up --env=dev
```

Once provisioning is complete, the Solr dashboard is accessible from
[http://&lt;environment&gt;.search-solr.apps.int.nsidc.org:8983/solr](), where
&lt;environment&gt; is one of dev, integration, qa, etc.

Additionally if the VM is brought up via the CI jenkins job (as defined in ci.yaml)
[search-solr-tools](https://github.com/nsidc/search-solr-tools) will be deployed
 and available on the newly-provisioned machine.

# Requirements and Setup for Non-NSIDC users

## Requirements

When using the project outside of the NSIDC environment, the configuration that would normally
be applied via the configuration in puppet/* will not be applied, and solr will
not be setup to run.

To use this project you will have to set up an environment with the following
requirements met:

* [Solr 4.3.0](https://archive.apache.org/dist/lucene/solr/4.3.0/) installed
* All [requirements](https://lucene.apache.org/solr/4_3_0/SYSTEM_REQUIREMENTS.html) for Solr 4.3.0

## Setup

(These actions should mirror the actions being applied by puppet in the `puppet/site.pp` manifest)

* Download the SOLR source and unpack it:

```
  tar -xvzf solr-4.3.0.tgz
```

*  Copy the 'collection1' core directory to add all the defaults/create the `nsidc_oai` and `auto_suggest` cores:

```
cd ${solr_path}/example/solr`
cp -Rp collection1 nsidc_oai
cp -Rp collection1 auto_suggest
rm -Rf collection1
```

* Copy the following files from this repo to the listed target directories to configure SOLR:

```
config/solr.xml -> ${solr_path}/example/solr/solr.xml
config/solrconfig.nsidc_oai.xml ->  ${solr_path}/example/solr/nsidc_oai/conf/solrconfig.xml
config/solrconfig.autosuggest.xml -> ${solr_path}/example/solr/auto_suggest/conf/solrconfig.xml
config/schema.xml -> ${solr_path}/example/solr/nsidc_oai/conf/schema.xml
config/schema.autosuggest.xml -> ${solr_path}/example/solr/auto_suggest/conf/schema.xml
```

* Start SOLR:

```
cd ${solr_path}/example
java -jar start.jar
```

Please note that this should serve only as an example of how to configure solr utilizing our configuration with the example from the solr distribution.  Before utilizing this example in a non-experimental setting you should consider utilizing a proper webserver (e.g. jetty) and configuring the location/cores/etc as applies to your particular environment.

# Development

Instructions and notes for developing this project are in
[DEVELOPMENT](https://github.com/nsidc/search-solr/blob/master/DEVELOPMENT.md).
