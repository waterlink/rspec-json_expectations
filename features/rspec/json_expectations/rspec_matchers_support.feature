Feature: RSpec matcher support for include_json matcher

  As a developer extensively testing my APIs
  I want to utilize the power of available RSpec matchers

  Background:
    Given a file "spec/spec_helper.rb" with:
          """ruby
          require "rspec"
          require "rspec/expectations"
          require "rspec/json_expectations"
          """
      And a local "SIMPLE_JSON" with:
          """json
          {
            "id": 25,
            "email": "john.smith@example.com",
            "name": "John",
            "score": 55
          }
          """

  Scenario: Expecting json string to include simple json using an rspec matcher
    Given a file "spec/matcher_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{SIMPLE_JSON}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                id: 25,
                email: "john.smith@example.com",
                name: "John",
                score: (be > 30)
              )
            end
          end
          """
     When I run "rspec spec/matcher_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string to include simple json using an rspec alias matcher
    Given a file "spec/matcher_example_spec.rb" with:
           """ruby
           require "spec_helper"

           RSpec.describe "A json response" do
             subject { '%{SIMPLE_JSON}' }

             it "has basic info about user" do
               expect(subject).to include_json(
                 id: a_kind_of(Numeric),
                 email: "john.smith@example.com",
                 name: "John",
                 score: (be > 30)
               )
             end
           end
           """
     When I run "rspec spec/matcher_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string to include simple json using an rspec matcher with failure
    Given a file "spec/matcher_example_fail_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{SIMPLE_JSON}' }

            it "has basic info about user" do
              matcher = be < 30
              puts "\'matcher.inspect\'"
              expect(subject).to include_json(
                id: 25,
                email: "john.smith@example.com",
                name: "John",
                score: (be < 30)
              )
            end
          end
          """
     When I run "rspec spec/matcher_example_fail_spec.rb"
     Then I see:
          """
                             expected: "be < 30"
                                  got: 55
          """
      And I see:
          """
          1 example, 1 failure
          """
