require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'crib'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

require 'support/fake'

RSpec.configure do |config|
  config.order = 'random'
  config.before(:each) { stub_request(:any, /api.fake.com/).to_rack(Fake) }
end
