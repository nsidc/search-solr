## Unreleased

  - Update VM provisioning to rotate search-solr-tool logs

## v5.1.0 (2023-08-21)

  - Update CI machine configuration

## v5.0.0 (2023-08-14)

  - Update CI configuration to use main instead of master.
  - Update Vagrant/Puppet templates and configuration to use Puppet 7
  - Update Ruby to use v3.2.2, along with updates to gem dependencies
  - Update Solr Puppet module to use Solr 9.3

## v4.3.0 (2022-08-31)

  - Bump search-solr-tools gem to fix bug with retrieving identifiers during
    harvesting

## v4.2.0 (2022-04-25)

  - Minor modifications to Puppetfile to be compatible with some changes
    to the puppet-nsidc-solr module, which was updated to fix a Log4j 
    vulnerability.

## v4.1.0 (2020-07-24)

  - Bump search-solr-tools gem to allow for better error handling of harvests

## v4.0.0 (2020-07-07)

  - Bump solr version to use 8.5.2 (via Puppet module)
  - Bump `search-solr-tools` version, no functional changes just ruby
    version and dependency updates.

## v3.1.0 (2019-08-13)

  - Bump `search-solr-tools` version. Retired datasets will now be excluded from
    search.

## v3.0.3 (2019-08-07)

  - Update configuration for segment handling as a safeguard against "out of
    memory" errors.

Note: This version originally included Vagrantfile steps to increase the VM's
memory in the staging and production environments, but that change was reverted
out of concern that it might have some influence on search results. The settings
for a 4GB memory build are illustrated in commit `#f48b172`.

## v3.0.2 (2019-07-12)

  - Update paths to acceptance tests and include `spec` directory when rsyncing
    to provisioned machine.
  - Force XML responses in acceptance test queries.
  - Remove `solr.xml` file (default version from the Solr installation is
    currently being used).

## v3.0.1 (2019-07-11)

  - Use latest version of `search-solr-tools` gem when building VM.
  - Modify CI job configuration for deploying `search-solr-tools` to simply do a
    `bundle install`.
  - Modify CI job configuration to use `bundle exec` when executing
    `search-solr-tools`.
  - Attempt to update Solr configuration files in a way that incorporates
    existing NSIDC configuration (unless the configuration causes Solr ingest
    errors) with new Solr defaults. Remove Solr defaults that appear to be
    irrelevant to NSIDC's needs.
  - Update Ruby version in Gemfile (originally intended this change to be part of the SRCH-15 work).

## v3.0.0 (2019-07-02)

  - Use default configuration for solr.xml and to initialize directories for configured cores.
  - Use managed schema instead of classic schema for configured cores.
  - Use built-in deployment script to set up Solr.
  - Install `search_solr_tools` via `Gemfile`.
  - Update Vagrant and Puppet plugins as needed to support latest Solr installation.
  - Updated CI jobs for ADE (remove inactive data center; update URLs for others).

## v2.0.2 (2015-07-01)

  - Add R2R to list of ADE data centers to harvest (added to harvest with v3.2.0
    of search_solr_tools)

## v2.0.1 (2015-06-29)

  - Update project documentation.

## v2.0.0 (2015-06-15)

  - Upgrade from Ruby version 1.9.3 to 2.2.2
  - Use the new search_solr_tools gem, rather than cloning the search-solr-tools
    project and running its `rake` tasks.

## v1.0.0 (2015-06-05)

  - add charFilter so accented characters are searchable without the accents,
    e.g., search for "Quebec" *will* find "Québec"

## v0.0.3 (2015-02-09)

  - Removed unused rake tasks.
  - Updates for the README.

## v0.0.1 (2015-2-3)

Features:

  - Installs Solr with default configuration on a virtual machine.
