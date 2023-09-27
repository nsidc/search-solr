# nsidc-search-solr

This vagrant project stands up a Solr instance for NSIDC Search / Arctic Data
Explorer.

See
[CHANGELOG.md](https://github.com/nsidc/search-solr/blob/main/CHANGELOG.md)
for information on past versions.

# Requirements and Setup at NSIDC

## Requirements
For use at NSIDC, this project requires the [vagrant-nsidc-plugin](https://bitbucket.org/nsidc/vagrant-nsidc-plugin).

Dependencies are defined in the CI configuration and should be available upon machine provision.

Although the `search-solr-tools` gem can be installed via Bundler, there is also a
separate Jenkins job to deploy the gem to a VM.  See the entries matching the
strings `deploy_solr_tools_command` and `Deploy_solr-search-tools-gem` in
`puppet/ci.yaml`.

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

## VM Memory Configuration

Solr appears to persistently run close to the limit of our standard 2GB VM
memory allocation.  If this becomes an issue, the VM memory allocation can be
bumped to 4GB (for example).  Commit `#f48b172` shows an example of the
Vagrantfile modifications needed to increase the memory allocation.

# Requirements and Setup for Non-NSIDC users

## Requirements

When using the project outside of the NSIDC environment, the configuration that
would normally be managed by Puppet will not be applied, and Solr will not be
installed.  You will have to manually set up an environment with an installed instance of
[Solr](http://lucene.apache.org/solr/downloads.html) and its dependencies
(`puppet-nsidc-solr` currently installs Solr version 9.3.0.).

Solr provides a deployment script to install the application:

```
/bin/tar -zxf solr-${solr_version}.tgz solr-${solr_version}/bin/install_solr_service.sh --strip-components=2
./install_solr_service.sh solr-${solr_version}.tgz
```

See the [DEVELOPMENT.md](https://github.com/nsidc/search-solr/blob/main/DEVELOPMENT.md).
file for additional instructions and development notes.
