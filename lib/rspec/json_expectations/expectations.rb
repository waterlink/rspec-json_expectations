require 'rspec'
require 'rspec/json_expectations'
require 'json'

module RSpec
  module JsonExpectations
    module Expectations
      extend self

      def it_conforms_to_json(json)
        generate_examples_for(json, called_in: caller[0])
      end

      private

      def generate_examples_for(json, opts)
        with_prefix = opts.fetch(:with_prefix, [])
        called_in = opts.fetch(:called_in)

        if json.is_a?(Hash)

          json.each do |key, new_json|
            new_prefix = with_prefix + [key.to_s]
            generate_examples_for(new_json, opts.merge(with_prefix: new_prefix))
          end

        elsif json.is_a?(Array)

          raise NotImplemented.new("Arrays are not allowed yet")

        elsif json.is_a?(String) || json.is_a?(Numeric)

          it "is expected to have equal value at json[\"#{with_prefix.join('"]["')}\"]" do
            value = JSON.parse(subject)
            with_prefix.each { |key| value = value[key.to_s] }
            begin
              expect(value).to eq(json)
            rescue Exception => e
              e.backtrace.delete_if { |line| line =~ RSpec::JsonExpectations::EXCLUSION_PATTERN }
              e.backtrace.insert(0, called_in)
              raise e
            end
          end

        end
      end

    end
  end
end
