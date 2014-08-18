require 'rspec'
require 'rspec/json_expectations'
require 'json'

module RSpec
  module JsonExpectations
    class JsonTraverser
      def self.traverse(errors, expected, actual, prefix=[])
        if expected.is_a?(Hash)

          expected.map do |key, value|
            new_prefix = prefix + [key]
            if actual.has_key?("#{key}")
              traverse(errors, value, actual["#{key}"], new_prefix)
            else
              errors[new_prefix.join("/")] = :no_key
              false
            end
          end.all?

        elsif expected.is_a?(String) || expected.is_a?(Numeric)

          if actual == expected
            true
          else
            errors[prefix.join("/")] = {
              actual: actual,
              expected: expected
            }
            false
          end

        else
          raise NotImplementedError, "#{expected} expectation is not supported"
        end
      end
    end
  end
end

RSpec::Matchers.define :include_json do |expected|
  match do |actual|
    unless expected.is_a?(Hash)
      raise ArgumentError, "Expected value must be a json for include_json matcher"
    end

    RSpec::JsonExpectations::JsonTraverser.traverse(
      example.metadata[:include_json_errors] = {},
      expected,
      JSON.parse(actual)
    )
  end

  # RSpec 2 vs 3
  send(respond_to?(:failure_message) ?
       :failure_message :
       :failure_message_for_should) do |actual|
         res = []

         example.metadata[:include_json_errors].each do |json_path, error|
           res << %{
           json atom on path "#{json_path}" is missing
           } if error == :no_key

           res << %{
           json atom on path "#{json_path}" is not equal to expected value:

             expected: #{error[:expected].inspect}
                  got: #{error[:actual].inspect}
           } if error.is_a?(Hash) && error.has_key?(:expected)
         end

         res.join("")
       end

end
