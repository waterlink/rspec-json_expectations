Feature: negation matching for include_json matcher

  As a developer extensively testing my APIs
  I want to be able to check if JSON response does not include some json part
  For that I need appropriate negation matching mechanism
  Where all json paths specified by include_json matcher should fail for
  expectation to succeed

  Background:
    Given a file "spec/spec_helper.rb" with:
          """ruby
          require "rspec/json_expectations"
          """
      And a local "SIMPLE_JSON" with:
          """json
          {
            "id": 25,
            "email": "john.smith@example.com",
            "name": "John"
          }
          """

  Scenario: Expecting json string not to incldue simple json
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{SIMPLE_JSON}' }

            it "has basic info about user" do
              expect(subject).not_to include_json(
                id: 26,
                email: "sarah@example.org",
                name: "Sarah C.",
                missing: "field"
              )
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string not to incldue simple json, when it is partially included
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{SIMPLE_JSON}' }

            it "has basic info about user" do
              expect(subject).not_to include_json(
                id: 26,
                email: /john.*@example.com/,
                name: "John",
                missing: "field"
              )
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          1 example, 1 failure
          """
      And I see:
          """
                           json atom at path "email" should not match expected regex:
          """
      And I see:
          """
                           json atom at path "name" should not equal to expected value:
          """

