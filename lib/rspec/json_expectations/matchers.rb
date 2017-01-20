require "forwardable"

RSpec::JsonExpectations::MatcherFactory.new(:include_json).define_matcher do
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

RSpec::JsonExpectations::MatcherFactory.new(:include_unordered_json).define_matcher do
  def traverse(expected, actual, negate=false)
    unless expected.is_a?(Array)
      raise ArgumentError,
        "Expected value must be a array for include_unordered_json matcher"
    end

    actual_json = actual
    actual_json = JSON.parse(actual) if String === actual

    expected_wrapped_in_unordered_array = \
      RSpec::JsonExpectations::Matchers::UnorderedArrayMatcher.new(expected)

    RSpec::JsonExpectations::JsonTraverser.traverse(
      @include_json_errors = { _negate: negate },
      expected_wrapped_in_unordered_array,
      actual_json,
      negate
    )
  end
end

RSpec::JsonExpectations::MatcherFactory.new(:match_unordered_json).define_matcher do
  def traverse(expected, actual, negate=false)
    unless expected.is_a?(Array)
      raise ArgumentError,
        "Expected value must be a array for match_unordered_json matcher"
    end

    actual_json = actual
    actual_json = JSON.parse(actual) if String === actual

    expected_wrapped_in_unordered_array = \
      RSpec::JsonExpectations::Matchers::UnorderedArrayMatcher.new(expected)

    RSpec::JsonExpectations::JsonTraverser.traverse(
      @include_json_errors = { _negate: negate },
      expected_wrapped_in_unordered_array,
      actual_json,
      negate,
      [],
      { match_size: true }
    )
  end
end

module RSpec
  module JsonExpectations
    module Matchers
      class UnorderedArrayMatcher
        extend Forwardable

        attr_reader :array

        def_delegators :array, :size

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

        def unwrap_array
          array
        end
      end

      def UnorderedArray(*array)
        UnorderedArrayMatcher.new(array)
      end
    end
  end
end
