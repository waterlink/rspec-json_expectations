require "json"

module RSpec
  module JsonExpectations
    # This class allows to traverse a json actual value along
    # with json expected value for inclusion and check if they
    # match. Errors are accumulated in errors hash for each
    # json atom paths.
    class JsonTraverser
      SUPPORTED_VALUES = [Hash, String, Numeric, Regexp, Array]

      class << self
        def traverse(errors, expected, actual, prefix=[])
          [
            handle_hash(errors, expected, actual, prefix),
            handle_array(errors, expected, actual, prefix),
            handle_value(errors, expected, actual, prefix),
            handle_regex(errors, expected, actual, prefix),
            handle_unsupported(expected)
          ].any?
        end

        private

        def handle_keyvalue(errors, expected, actual, prefix=[])
          expected.map do |key, value|
            new_prefix = prefix + [key]
            if has_key?(actual, key)
              traverse(errors, value, fetch(actual, key), new_prefix)
            else
              errors[new_prefix.join("/")] = :no_key
              false
            end
          end.all? || false
        end

        def handle_hash(errors, expected, actual, prefix=[])
          return nil unless expected.is_a?(Hash)

          handle_keyvalue(errors, expected, actual, prefix)
        end

        def handle_array(errors, expected, actual, prefix=[])
          return nil unless expected.is_a?(Array)

          transformed_expected = expected.each_with_index.map { |v, k| [k, v] }
          handle_keyvalue(errors, transformed_expected, actual, prefix)
        end

        def handle_value(errors, expected, actual, prefix=[])
          return nil unless expected.is_a?(String) || expected.is_a?(Numeric)

          if actual == expected
            true
          else
            errors[prefix.join("/")] = {
              actual: actual,
              expected: expected
            }
            false
          end
        end

        def handle_regex(errors, expected, actual, prefix=[])
          return nil unless expected.is_a?(Regexp)

          if expected.match(actual)
            true
          else
            errors[prefix.join("/")] = {
              actual: actual,
              expected: expected
            }
            false
          end
        end

        def handle_unsupported(expected)
          unless SUPPORTED_VALUES.any? { |type| expected.is_a?(type) }
            raise NotImplementedError,
              "#{expected} expectation is not supported"
          end
        end

        def has_key?(actual, key)
          if actual.is_a?(Hash)
            actual.has_key?(key.to_s)
          elsif actual.is_a?(Array)
            actual.count > key
          else
            false
          end
        end

        def fetch(actual, key, default=nil)
          if actual.is_a?(Hash)
            actual[key.to_s]
          elsif actual.is_a?(Array)
            actual[key]
          else
            default
          end
        end

      end
    end
  end
end
