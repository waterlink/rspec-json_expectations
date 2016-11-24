module RSpec
  module JsonExpectations
    class IncludeJsonMatcher
      def initialize
        @matcher_name = nil
        @traverse_method = nil
      end

      def set_matcher_name(matcher_name)
        @matcher_name = matcher_name
        self
      end

      def set_traverse_method(&traverse_method)
        @traverse_method = traverse_method
        self
      end

      def define_matcher
        _define_matcher do
          def traverse(expected, actual, negate=false)
            @traverse_method.call expected, actual, negate
          end
        end
      end

      def _define_matcher
        RSpec::Matchers.define @matcher_name do |expected|
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

          instance_eval yield

        end
      end
    end
  end
end
