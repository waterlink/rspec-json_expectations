# RSpec::JsonExpectations

[![Build Status](https://travis-ci.org/waterlink/rspec-json_expectations.svg?branch=master)](https://travis-ci.org/waterlink/rspec-json_expectations)

Set of matchers and helpers for RSpec 3 to allow you test your JSON API responses like a pro.

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-json_expectations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-json_expectations

## Setup

Simply add this line at the top of your spec helper:

```ruby
require "rspec/json_expectations"
```

## Usage

Simple example:

```ruby
require "spec_helper"

RSpec.describe "User API" do
  subject { api_get :user }

  it "has basic info about user" do
    expect(subject).to include_json(
      id: 25,
      email: "john.smith@example.com",
      name: "John"
    )
  end

  it "has some additional info about user" do
    expect(subject).to include_json(
      premium: "gold",
      gamification_score: 79
    )
  end
end
```

And the output when I run it is:

```
FF

Failures:

  1) User API has basic info about user
     Failure/Error: expect(subject).to include_json(

                 json atom at path "id" is not equal to expected value:

                   expected: 25
                        got: 37

                 json atom at path "name" is not equal to expected value:

                   expected: "John"
                        got: "Smith J."

     # ./spec/user_api_spec.rb:18:in `block (2 levels) in <top (required)>'

  2) User API has some additional info about user
     Failure/Error: expect(subject).to include_json(

                 json atom at path "premium" is not equal to expected value:

                   expected: "gold"
                        got: "silver"

     # ./spec/user_api_spec.rb:26:in `block (2 levels) in <top (required)>'

Finished in 0.00102 seconds (files took 0.0853 seconds to load)
2 examples, 2 failures

Failed examples:

rspec ./spec/user_api_spec.rb:17 # User API has basic info about user
rspec ./spec/user_api_spec.rb:25 # User API has some additional info about user
```

For other features look into documentation: https://www.relishapp.com/waterlink/rspec-json-expectations/docs/json-expectations

## Development

- `bundle install` to install all dependencies.
- `bin/build` to run the test suite

## Contributing

1. Fork it ( https://github.com/waterlink/rspec-json_expectations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
