RSpec::Matchers.define :include_json do |expected|

  # RSpec 2 vs 3
  if respond_to?(:failure_message)
    match do |actual|
      traverse(expected, actual, false)
    end

    match_when_negated do |actual|
      traverse(expected, actual, true)
    end

    failure_message do |actual|
       RSpec::JsonExpectations::FailurePresenter.render(@include_json_errors)
    end

    failure_message_when_negated do |actual|
       RSpec::JsonExpectations::FailurePresenter.render(@include_json_errors)
    end
  else
    match_for_should do |actual|
      traverse(expected, actual, false)
    end

    match_for_should_not do |actual|
      traverse(expected, actual, true)
    end

    failure_message_for_should do |actual|
      RSpec::JsonExpectations::FailurePresenter.render(@include_json_errors)
    end

    failure_message_for_should_not do |actual|
      RSpec::JsonExpectations::FailurePresenter.render(@include_json_errors)
    end
  end

  def traverse(expected, actual, negate=false)
    unless expected.is_a?(Hash) ||
        expected.is_a?(Array) ||
        expected.is_a?(::RSpec::JsonExpectations::Matchers::UnorderedArrayMatcher)
      raise ArgumentError,
        "Expected value must be a json for include_json matcher"
    end

    representation = actual
    representation = JSON.parse(actual) if String === actual

    RSpec::JsonExpectations::JsonTraverser.traverse(
      @include_json_errors = { _negate: negate },
      expected,
      representation,
      negate
    )
  end
end

module RSpec
  module JsonExpectations
    module Matchers
      class UnorderedArrayMatcher
        attr_reader :array
        def initialize(array)
          @array = array
        end

        def match(errors, actual, prefix)
          missing_items = []
          errors[prefix.join("/")] = { missing: missing_items }

          all? do |expected_item, index|
            match_one(missing_items, expected_item, index, actual)
          end
        end

        def match_one(missing, item, index, actual)
          check_for_missing(missing, item, index,
            actual.any? do |actual_item|
              JsonTraverser.traverse({}, item, actual_item, false)
            end
          )
        end

        def check_for_missing(missing, item, index, ok)
          missing << { item: item, index: index } unless ok
          ok
        end

        def all?(&blk)
          array.each_with_index.all?(&blk)
        end
      end

      def UnorderedArray(*array)
        UnorderedArrayMatcher.new(array)
      end
    end
  end
end
