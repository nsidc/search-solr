Feature: Solr Basics
  Background:
    Given I am using the current environment settings

  Scenario: Successful Response
    Given I search for "sea ice"
    Then I should get a valid response with results

  Scenario: Accented Search
    Given I search for "Québec"
    And I search for "Quebec"
    Then The last 2 searches should have the same number of results
