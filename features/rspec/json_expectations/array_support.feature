Feature: Array matching support for include_json matcher

  As a developer extensively testing my APIs
  I want to be able to match json parts with array

  Background:
    Given a file "spec/spec_helper.rb" with:
          """ruby
          require "rspec/json_expectations"
          """
      And a local "JSON_WITH_ARRAY" with:
          """json
          {
            "per_page": 3,
            "count": 17,
            "page": 2,
            "page_count": 6,
            "results": [
              {
                "id": 25,
                "email": "john.smith@example.com",
                "badges": ["first flight", "day & night"],
                "name": "John"
              },
              {
                "id": 26,
                "email": "john.smith@example.com",
                "badges": ["first flight"],
                "name": "John"
              },
              {
                "id": 27,
                "email": "john.smith@example.com",
                "badges": ["day & night"],
                "name": "John"
              }
            ]
          }
          """
      And a local "JSON_WITH_ROOT_ARRAY" with:
          """json
          [
            "first flight",
            "day & night"
          ]
          """

  Scenario: Expecting json string to fully include json with arrays
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                results: [
                  { id: 25, badges: ["first flight", "day & night"] },
                  { id: 26, badges: ["first flight"] },
                  { id: 27, badges: ["day & night"] }
                ]
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting wrong json string to fully include json with arrays
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                results: [
                  { id: 24, badges: [] },
                  { id: 25, badges: ["first flight", "day & night"] },
                  { id: 26, badges: ["first flight"] },
                  { id: 27, badges: ["day & night"] }
                ]
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
                           json atom at path "results/0/id" is not equal to expected value:
          """
      And I see:
          """
                           json atom at path "results/1/id" is not equal to expected value:
          """
      And I see:
          """
                           json atom at path "results/1/badges/1" is missing
          """
      And I see:
          """
                           json atom at path "results/2/id" is not equal to expected value:
          """
      And I see:
          """
                           json atom at path "results/2/badges/0" is not equal to expected value:
          """
      And I see:
          """
                             expected: "first flight"
                                  got: "day & night"
          """
      And I see:
          """
                           json atom at path "results/3" is missing
          """

  Scenario: Expecting json string to partially include json with arrays
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                results: {
                  2 => { id: 27, badges: ["day & night"] }
                }
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting wrong json string to partially include json with arrays
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                results: {
                  2 => { id: 28, badges: ["day & night"] }
                }
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
                           json atom at path "results/2/id" is not equal to expected value:
          """

  Scenario: Expecting json string with array at root to fully include json with arrays
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ROOT_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                [ "first flight", "day & night" ]
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting wrong json string with array at root to fully include json with arrays
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ROOT_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                [ "first flight", "day & night", "super hero" ]
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
                           json atom at path "2" is missing
          """
