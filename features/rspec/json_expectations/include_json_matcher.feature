Feature: include_json matcher

  As a developer extensively testing my APIs with RSpec
  I want to have a suitable tool to test my API responses
  And I want to use simple ruby hashes to describe the parts of response
  For that I need a custom matcher

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
      And a local "BIG_JSON" with:
          """json
          {
            "id": 25,
            "email": "john.smith@example.com",
            "password_hash": "super_md5_hash_that_is_unbreakable",
            "name": "John",
            "profile_id": 39,
            "role": "admin"
          }
          """

  Scenario: Expecting json string to include simple json
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{SIMPLE_JSON}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                id: 25,
                email: "john.smith@example.com",
                name: "John"
              )
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting wrong json string to include simple json
    Given a file "spec/simple_with_fail_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{SIMPLE_JSON}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                id: 37,
                email: "john.smith@example.com",
                name: "Smith"
              )
            end
          end
          """
     When I run "rspec spec/simple_with_fail_spec.rb"
     Then I see:
          """
          1 example, 1 failure
          """
      And I see:
          """
                             expected: 37
                                  got: 25
          """
      And I see:
          """
                             expected: "Smith"
                                  got: "John"
          """
      And I see:
          """ruby
          # ./spec/simple_with_fail_spec.rb
          """

  Scenario: Expecting json response with excessive fields to include 'smaller' json
    Given a file "spec/excessive_fields_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{BIG_JSON}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                id: 25,
                name: "John",
                profile_id: 39,
                role: "admin"
              )
            end
          end
          """
     When I run "rspec spec/excessive_fields_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

