module Crib
  # Defines an explorable REST API
  #
  # @example Define the GitHub API with a HTTP header
  #   Crib::API.new('https://api.github.com') do |c|
  #     c.headers[:user_agent] = 'crib'
  #   end
  class API
    # @return [Sawyer::Agent] request handler
    attr_reader :_agent

    # @return [Sawyer::Response, nil] most recent response, if any
    attr_accessor :_last_response

    # Defines an API by constructing a request handler
    #
    # @param endpoint [String] API endpoint
    # @param sawyer_options [Hash] options for Sawyer
    # @param block [Block] block for Sawyer
    def initialize(endpoint, sawyer_options = {}, &block)
      @_agent = Sawyer::Agent.new(
        endpoint,
        sawyer_options.merge(links_parser: Sawyer::LinkParsers::Simple.new),
        &block
      )
    end

    private

    def method_missing(method_name, *args)
      Request.new(self, Helpers.construct_path(method_name, args))
    end
  end
end
