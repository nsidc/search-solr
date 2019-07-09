## Unreleased

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
