require 'simplecov'
SimpleCov.start

require 'crib'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

require 'support/github'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.before(:each) { stub_request(:any, /api.github.com/).to_rack(GitHub) }
end
