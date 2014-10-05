module RSpec
  module JsonExpectations
    # Allows to present failures in a nice way for each json path
    class FailurePresenter
      class << self
        def render(errors)
          negate = errors[:_negate]
          errors.map { |path, error| render_error(path, error, negate) }.join
        end

        private

        def render_error(path, error, negate=false)
          [
            render_no_key(path, error, negate),
            render_not_eq(path, error, negate),
            render_not_match(path, error, negate)
          ].select { |e| e }.first
        end

        def render_no_key(path, error, negate=false)
          %{
          json atom at path "#{path}" is missing
          } if error == :no_key
        end

        def render_not_eq(path, error, negate=false)
          %{
          json atom at path "#{path}" #{negate ? "should" : "is"} not equal to expected value:

            expected: #{error[:expected].inspect}
                 got: #{error[:actual].inspect}
          } if error_is_not_eq?(error)
        end

        def render_not_match(path, error, negate=false)
          %{
          json atom at path "#{path}" #{negate ? "should" : "does"} not match expected regex:

            expected: #{error[:expected].inspect}
                 got: #{error[:actual].inspect}
          } if error_is_not_match?(error)
        end

        def error_is_not_eq?(error)
          error.is_a?(Hash) && error.has_key?(:expected) && !error[:expected].is_a?(Regexp)
        end

        def error_is_not_match?(error)
          error.is_a?(Hash) && error.has_key?(:expected) && error[:expected].is_a?(Regexp)
        end
      end
    end
  end
end
