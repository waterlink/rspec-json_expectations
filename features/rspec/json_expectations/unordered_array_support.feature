Feature: Unordered array matching support for include_json matcher

  As a developer extensively testing my APIs
  I want to be able to match json parts with array
  And I don't want to be explicit about the order of the elements

  Background:
    Given a file "spec/spec_helper.rb" with:
          """ruby
          require "rspec/json_expectations"

          RSpec.configure do |c|
            c.include RSpec::JsonExpectations::Matchers
          end
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
                results: UnorderedArray(
                  { id: 25, badges: ["first flight", "day & night"] },
                  { id: 26, badges: ["first flight"] },
                  { id: 27, badges: ["day & night"] }
                )
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string to fully include json with arrays with different order
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                results: UnorderedArray(
                  { id: 26, badges: ["first flight"] },
                  { id: 27, badges: ["day & night"] },
                  { id: 25, badges: ["first flight", "day & night"] }
                )
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string to fully include json with wrong values
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                results: UnorderedArray(
                  { id: 26, badges: ["first flight"] },
                  { id: 35, badges: ["unknown", "badge"] },
                  { id: 27, badges: ["day & night"] },
                  { id: 25, badges: ["first flight", "day & night"] }
                )
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
                           json atom at path "results/1" is missing
          """
      And I see:
          """
                             expected: {:id=>35, :badges=>["unknown", "badge"]}
                                  got: nil
          """

  Scenario: Expecting json string with array at root to fully include json with arrays
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ROOT_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                UnorderedArray( "first flight", "day & night" )
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string with array at root to fully include json with arrays using alternative syntax
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ROOT_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_unordered_json ["first flight", "day & night"]
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string with array at root to fully include json with arrays with different order
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ROOT_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                UnorderedArray( "day & night", "first flight" )
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string with array at root to fully include json with arrays with different order using alternative syntax
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ROOT_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_unordered_json ["day & night", "first flight"]
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string with array at root to fully include json with wrong values
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ROOT_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                UnorderedArray( "day & night", "unknown", "first flight" )
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
                           json atom at path "1" is missing
          """
      And I see:
          """
                             expected: "unknown"
                                  got: nil
          """

  Scenario: Expecting json string with array at root to fully include json with wrong values using alternative syntax
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{JSON_WITH_ROOT_ARRAY}' }

            it "has basic info about user" do
              expect(subject).to include_unordered_json ["day & night", "unknown", "first flight"]
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
                           json atom at path "1" is missing
          """
      And I see:
          """
                             expected: "unknown"
                                  got: nil
          """
