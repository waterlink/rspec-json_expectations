require "json"

module RSpec
  module JsonExpectations
    # This class allows to traverse a json actual value along
    # with json expected value for inclusion and check if they
    # match. Errors are accumulated in errors hash for each
    # json atom paths.
    class JsonTraverser
      SUPPORTED_VALUES = [Hash, String, Numeric]

      class << self
        def traverse(errors, expected, actual, prefix=[])
          [
            handle_hash(errors, expected, actual, prefix),
            handle_value(errors, expected, actual, prefix),
            handle_unsupported(expected)
          ].any?
        end

        private

        def handle_hash(errors, expected, actual, prefix=[])
          return nil unless expected.is_a?(Hash)

          expected.map do |key, value|
            new_prefix = prefix + [key]
            if actual.has_key?("#{key}")
              traverse(errors, value, actual["#{key}"], new_prefix)
            else
              errors[new_prefix.join("/")] = :no_key
              false
            end
          end.all? || false
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

        def handle_unsupported(expected)
          unless SUPPORTED_VALUES.any? { |type| expected.is_a?(type) }
            raise NotImplementedError,
              "#{expected} expectation is not supported"
          end
        end

      end
    end
  end
end
