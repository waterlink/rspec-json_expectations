Feature: nested json support with include_json matcher

  As a developer extensively testing my APIs
  I want to be able to easily test nested JSON responses

  Background:
    Given a file "spec/spec_helper.rb" with:
          """ruby
          require "rspec/json_expectations"
          """
      And a local "NESTED_JSON" with:
          """json
          {
            "id": 25,
            "email": "john.smith@example.com",
            "gamification": {
              "rating": 93,
              "score": 397
            },
            "name": "John"
          }
          """

  Scenario: Expecting json string to include nested json
    Given a file "spec/nested_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{NESTED_JSON}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                id: 25,
                email: "john.smith@example.com",
                name: "John"
              )
            end

            it "has gamification info for user" do
              expect(subject).to include_json(
                gamification: {
                  rating: 93,
                  score: 355
                }
              )
            end
          end
          """
     When I run "rspec spec/nested_example_spec.rb"
     Then I see:
          """
          2 examples, 1 failure
          """
      And I see:
          """
                           json atom at path "gamification/score" is not equal to expected value:
          """
      And I see:
          """
                             expected: 355
                                  got: 397
          """
