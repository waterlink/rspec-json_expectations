RSpec::Matchers.define :include_json do |expected|
  match do |actual|
    unless expected.is_a?(Hash)
      raise ArgumentError,
        "Expected value must be a json for include_json matcher"
    end

    RSpec::JsonExpectations::JsonTraverser.traverse(
      @include_json_errors = {},
      expected,
      JSON.parse(actual)
    )
  end

  # RSpec 2 vs 3
  send(respond_to?(:failure_message) ?
       :failure_message :
       :failure_message_for_should) do |actual|
         RSpec::JsonExpectations::FailurePresenter.render(@include_json_errors)
       end

end
