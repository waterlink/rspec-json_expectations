Feature: include_json matcher with hash

  As a developer I want to be able to test not only JSON responses
  But I want to test my hashes to be correct and see nice error output on failures

  Background:
    Given a file "spec/spec_helper.rb" with:
          """ruby
          require "rspec/json_expectations"
          """

      And a local "SIMPLE_HASH" with:
          """ruby
          {
            id: 25,
            email: "john.smith@example.com",
            name: "John"
          }
          """

      And a local "BIG_HASH" with:
          """ruby
          {
            id: 25,
            email: "john.smith@example.com",
            password_hash: "super_md5_hash_that_is_unbreakable",
            name: "John",
            profile_id: 39,
            role: "admin"
          }
          """

      And a local "HASH_WITH_SIMPLE_TYPES" with:
          """ruby
          {
            phone: nil,
            name: "A guy without phone",
            without_phone: true,
            communicative: false
          }
          """

  Scenario: Expecting json string to include simple json
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { %{SIMPLE_HASH} }

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
            subject { %{SIMPLE_HASH} }

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
            subject { %{BIG_HASH} }

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

  Scenario: Expecting json response to contain null(s), booleans, etc
    Given a file "spec/nil_values_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { %{HASH_WITH_SIMPLE_TYPES} }

            it "has no phone" do
              expect(subject).to include_json(
                name: "A guy without phone",
                phone: nil,
                communicative: false,
                without_phone: true
              )
            end
          end
          """
     When I run "rspec spec/nil_values_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

