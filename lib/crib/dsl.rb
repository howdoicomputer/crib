module Crib
  # Contains DSL methods that aid API client creation
  class DSL
    extend Crib::Helpers::InheritableAttribute
    inheritable_attr :_api

    # @return [Crib::API] instance of API definition
    def api
      self.class._api
    end

    # @return [Sawyer::Response] most recent Sawyer response
    def last_response
      api._last_response
    end

    # Defines an API for the class
    #
    # @param endpoint [String] API endpoint
    # @param sawyer_options [Hash] options for Sawyer
    # @param block [Block] block for Sawyer
    # @example Define the GitHub API with HTTP header
    #   define 'https://api.github.com' do |c|
    #     c.headers[:user_agent] = 'crib'
    #   end
    def self.define(endpoint, sawyer_options = {}, &block)
      self._api ||= Crib::API.new(endpoint, sawyer_options, &block)
      self
    end

    # Defines an action on the class
    #
    # @param method [Symbol] action name
    # @param block [Block] block containing arguments/contents of action
    # @example Create action with two arguments, using {#api}
    #   action :issues do |repo, options = {}|
    #     api.repos(*repo.split('/')).issues._get(options)
    #   end
    def self.action(method, &block)
      send(:define_method, method, &block)
      self
    end
  end
end
