require "rspec"
require "rspec/json_expectations"

RSpec::JsonExpectations::EXCLUSION_PATTERN = %r{lib/rspec/json_expectations}

def enable_json_expectations!

  # rspec 3
  if defined?(RSpec::CallerFilter)
    if defined?(RSpec::CallerFilter::IGNORE_REGEX)
      ignore_regex = RSpec::CallerFilter::IGNORE_REGEX
      RSpec::CallerFilter.send(:remove_const, 'IGNORE_REGEX')
      RSpec::CallerFilter.send(:const_set, 'IGNORE_REGEX', Regexp.union(
        ignore_regex,
        RSpec::JsonExpectations::EXCLUSION_PATTERN
      ))
      # rspec 3, but older
    elsif defined?(RSpec::CallerFilter::LIB_REGEX)
      ignore_regex = RSpec::CallerFilter::LIB_REGEX
      RSpec::CallerFilter.send(:remove_const, 'LIB_REGEX')
      RSpec::CallerFilter.send(:const_set, 'LIB_REGEX', Regexp.union(
        ignore_regex,
        RSpec::JsonExpectations::EXCLUSION_PATTERN
      ))
    end
    # rspec 2
  else
    RSpec::Core::Metadata::MetadataHash.send(:define_method, :first_caller_from_outside_rspec) do
      self[:caller].detect {|l| l !~ /\/lib\/rspec\/(core|json_expectations)/}
    end
  end

  RSpec.configure do |config|
    config.extend(RSpec::JsonExpectations::Expectations)

    if config.respond_to?(:backtrace_exclusion_patterns)
      # rspec 3
      config.backtrace_exclusion_patterns << RSpec::JsonExpectations::EXCLUSION_PATTERN
    else
      # rspec 2
      config.backtrace_clean_patterns << RSpec::JsonExpectations::EXCLUSION_PATTERN
    end
  end

end
