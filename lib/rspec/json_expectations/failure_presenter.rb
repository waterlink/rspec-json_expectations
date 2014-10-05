module RSpec
  module JsonExpectations
    # Allows to present failures in a nice way for each json path
    class FailurePresenter
      class << self
        def render(errors)
          errors.map { |path, error| render_error(path, error) }.join
        end

        private

        def render_error(path, error)
          [
            render_no_key(path, error),
            render_not_eq(path, error),
            render_not_match(path, error)
          ].select { |e| e }.first
        end

        def render_no_key(path, error)
          %{
          json atom at path "#{path}" is missing
          } if error == :no_key
        end

        def render_not_eq(path, error)
          %{
          json atom at path "#{path}" is not equal to expected value:

            expected: #{error[:expected].inspect}
                 got: #{error[:actual].inspect}
          } if error_is_not_eq?(error)
        end

        def render_not_match(path, error)
          %{
          json atom at path "#{path}" does not match expected regex:

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
