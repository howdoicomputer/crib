require 'sawyer'

require 'crib/helpers'

require 'crib/api'
require 'crib/request'

require 'crib/version'

# A dynamic way of quickly exploring REST APIs
module Crib
  class << self
    # A collection of {Crib::API} instances
    attr_reader :apis

    # Create new {Crib::API}
    #
    # @param endpoint [String] API endpoint
    # @param sawyer_options [Hash] options for Sawyer
    # @param block [Block] block for Sawyer
    # @return [Crib::API]
    def api(endpoint, sawyer_options = {}, &block)
      @apis ||= []
      @apis.push(API.new(endpoint, sawyer_options, block)).last
    end
  end
end
