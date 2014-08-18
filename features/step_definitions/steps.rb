DUMMY_FOLDER = "dummy"

def init
  `mkdir -p #{DUMMY_FOLDER}`
  `cp -r gemfiles #{DUMMY_FOLDER}`
  `cp *.gemspec #{DUMMY_FOLDER}`
  `cp -r lib #{DUMMY_FOLDER}`
end

init

Given(/^a file "(.*?)" with:$/) do |filename, contents|
  @locals ||= {}
  full_path = File.join(DUMMY_FOLDER, filename)
  `mkdir -p #{File.dirname(full_path)}`
  File.open(full_path, 'w') { |f| f.write(contents % @locals) }
end

Given(/^a local "(.*?)" with:$/) do |key, value|
  @locals ||= {}
  @locals[key.to_sym] = value
end

When(/^I run "(.*?)"$/) do |command|
  @output = `cd #{DUMMY_FOLDER}; #{command}`
  puts @output
end

Then(/^I see:$/) do |what|
  @output ||= ""
  expect(@output).to include(what)
end
