require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'crib'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

require 'support/fake'

RSpec.configure do |config|
  config.order = 'random'
  config.before(:each) { stub_request(:any, /api.fake.com/).to_rack(Fake) }
end
