Feature: it_conforms_to_json syntax

  Background:
    Given a file "spec/spec_helper.rb" with:
          """
          require "rspec/json_expectations"
          enable_json_expectations!
          """
      And a local "SIMPLE_JSON" with:
          """
          {
            "id": 25,
            "email": "john.smith@example.com",
            "name": "John"
          }
          """
      And a local "BIG_JSON" with:
          """
          {
            "id": 25,
            "email": "john.smith@example.com",
            "password_hash": "super_md5_hash_that_is_unbreakable",
            "name": "John",
            "profile_id": 39,
            "role": "admin"
          }
          """

  Scenario: Simple usage example
    Given a file "spec/simple_example_spec.rb" with:
          """
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{SIMPLE_JSON}' }

            it_conforms_to_json(
              id: 25,
              email: "john.smith@example.com",
              name: "John"
            )
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          3 examples, 0 failures
          """

  Scenario: Simple usage with failure
    Given a file "spec/simple_with_fail_spec.rb" with:
          """
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{SIMPLE_JSON}' }

            it_conforms_to_json(
              id: 37,
              email: "john.smith@example.com",
              name: "Smith"
            )
          end
          """
     When I run "rspec spec/simple_with_fail_spec.rb"
     Then I see:
          """
          3 examples, 2 failures
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

  Scenario: Excessive fields on subject json are ignored
    Given a file "spec/excessive_fields_spec.rb" with:
          """
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{BIG_JSON}' }

            it_conforms_to_json(
              id: 25,
              name: "John",
              profile_id: 39,
              role: "admin"
            )
          end
          """
     When I run "rspec spec/excessive_fields_spec.rb"
     Then I see:
          """
          4 examples, 0 failures
          """

