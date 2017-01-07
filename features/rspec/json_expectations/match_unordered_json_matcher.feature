Feature: match_unordered_json matcher

  As a developer extensively testing my APIs with RSpec
  I want to have a suitable tool to test my API responses
  And I want to use simple ruby hashes to describe the parts of response
  For that I need a custom matcher

  Scenario: Expecting json array to match expected array
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '[1, 2, 3]' }

            it "matches when the order is equal and the size is equal" do
              expect(subject).to match_unordered_json([1, 2, 3])
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json array to match expected array with different order
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '[1, 2, 3]' }

            it "matches when the order is different but the size is equal" do
              expect(subject).to match_unordered_json([2, 3, 1])
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json array to not match a subcollection
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '[1, 2, 3]' }

            it "doesn't match if the size is different" do
              expect(subject).to match_unordered_json([1, 2])
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
                 json atom at path "" does not match the expected size:
          """
     And I see:
          """
                   expected collection contained:  [1, 2]
          """
     And I see:
          """
                   actual collection contained:    [1, 2, 3]
          """
     And I see:
          """
                   the extra elements were:        [3]
          """


  Scenario: Expecting json array to not match a subcollection
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '[1, 2, 3]' }

            it "doesn't match if the order is different and size is different" do
              expect(subject).to match_unordered_json([3, 1])
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
                 json atom at path "" does not match the expected size:
          """
     And I see:
          """
                   expected collection contained:  [3, 1]
          """
     And I see:
          """
                   actual collection contained:    [1, 2, 3]
          """
     And I see:
          """
                   the extra elements were:        [2]
          """

  Scenario: Expecting json array to successfully not match when the arrays do not match
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '[1, 2]' }

            it "successfully does not match when the the size is unequal" do
              expect(subject).to_not match_unordered_json([1, 2, 3])
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          1 example, 0 failures
          """

  Scenario: Expecting json array to fail to not match when the arrays do match
    Given a file "spec/simple_example_spec.rb" with:
          """ruby
          require "spec_helper"

          RSpec.describe "A json response" do
            subject { '[1, 2, 3]' }

            it "fails to not match when the arrays do match" do
              expect(subject).to_not match_unordered_json([1, 2, 3])
            end
          end
          """
     When I run "rspec spec/simple_example_spec.rb"
     Then I see:
          """
          1 example, 1 failure
          """
