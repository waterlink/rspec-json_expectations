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
    unless expected.is_a?(Hash) || expected.is_a?(Array)
      raise ArgumentError,
        "Expected value must be a json for include_json matcher"
    end

    RSpec::JsonExpectations::JsonTraverser.traverse(
      @include_json_errors = { _negate: negate },
      expected,
      JSON.parse(actual),
      negate
    )
  end
end
