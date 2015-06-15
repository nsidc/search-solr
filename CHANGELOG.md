## Unreleased

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
