Feature: regular expressions support with include_json matcher

  As a developer extensively testing my APIs
  I want to be able to match string values by regex

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
            "name": "John",
            "code": "5wmsx6ae7p",
            "url": "https://test.example.org/api/v5/users/5wmsx6ae7p.json"
          }
          """
      And a local "WRONG_JSON" with:
          """json
          {
            "id": 25,
            "email": "john.smith@example.com",
            "name": "John",
            "code": "5wmsx6ae7psome-trash",
            "url": "https://test.example.org/api/v6/users/5wmsx6ae7p.json"
          }
          """
      And a local "COMPLEX_JSON" with:
          """json
          {
            "balance": 25.0,
            "status": true,
            "avatar_url": null
          }
          """

  Scenario: Expecting json string to include typed json with regex
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{COMPLEX_JSON}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                balance: /\d/,
                status: /true|false/,
                avatar_url: /^?/
              )
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json string to include simple json with regex
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{SIMPLE_JSON}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                id: 25,
                email: "john.smith@example.com",
                name: "John",
                code: /^[a-z0-9]{10}$/,
                url: %%r{api/v5/users/[a-z0-9]{10}.json}
              )
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting wrong json string to include simple json with regex
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '%{WRONG_JSON}' }

            it "has basic info about user" do
              expect(subject).to include_json(
                id: 25,
                email: "john.smith@example.com",
                name: "John",
                code: /^[a-z0-9]{10}$/,
                url: %%r{api/v5/users/[a-z0-9]{10}.json}
              )
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
                           json atom at path "code" does not match expected regex:
          """
      And I see:
          """
                             expected: /^[a-z0-9]{10}$/
                                  got: "5wmsx6ae7psome-trash"
          """
      And I see:
          """
                           json atom at path "url" does not match expected regex:
          """
      And I see:
          """
                             expected: /api\/v5\/users\/[a-z0-9]{10}.json/
                                  got: "https://test.example.org/api/v6/users/5wmsx6ae7p.json"
          """
