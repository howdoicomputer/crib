module Crib
  # Defines an explorable REST API
  class API
    # Returns instance of Sawyer::Agent
    attr_reader :_agent

    # Returns latest Sawyer::Response
    attr_accessor :_last_response

    # Defines an API
    #
    # @param endpoint [String] API endpoint
    # @param sawyer_options [Hash] options for Sawyer
    # @param block [Block] block for Sawyer
    def initialize(endpoint, sawyer_options = {}, block = nil)
      @_agent = Sawyer::Agent.new(
        endpoint,
        sawyer_options.merge(links_parser: Sawyer::LinkParsers::Simple.new),
        &block
      )
    end

    private

    def method_missing(method_name, *args)
      Request.new(self, Helpers.construct_uri(method_name, args))
    end
  end
end
