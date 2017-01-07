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
            render_size_mismatch(path, error, negate),
            render_no_key(path, error, negate),
            render_not_eq(path, error, negate),
            render_not_match(path, error, negate),
            render_missing(path, error, negate)
          ].select { |e| e }.first
        end

        def render_size_mismatch(path, error, negate=false)
          %{
          json atom at path "#{path}" does not match the expected size:

            expected collection contained:  #{error[:expected].inspect}
            actual collection contained:    #{error[:actual].inspect}
            the extra elements were:        #{error[:extra_elements].inspect}

          } if error_is_size_mismatch?(error)
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

        def render_missing(path, error, negate=false)
          return unless error_is_missing?(error)

          prefix = "#{path}/" if path && !path.empty?

          items = error[:missing].map do |item|
            %{
          json atom at path "#{prefix}#{item[:index]}" is missing

            expected: #{item[:item].inspect}
                 got: nil
            }
          end.join("\n")
        end

        def error_is_size_mismatch?(error)
          error.is_a?(Hash) && error.has_key?(:_size_mismatch_error)
        end

        def error_is_not_eq?(error)
          error.is_a?(Hash) && error.has_key?(:expected) && !error[:expected].is_a?(Regexp)
        end

        def error_is_not_match?(error)
          error.is_a?(Hash) && error.has_key?(:expected) && error[:expected].is_a?(Regexp)
        end

        def error_is_missing?(error)
          error.is_a?(Hash) && error.has_key?(:missing)
        end
      end
    end
  end
end
