module Crib
  # Defines an API resource
  class Resource
    extend Crib::Helpers::InheritableAttribute
    inheritable_attr :_api

    # When creating a new instance, the API definition can be set/overridden
    #
    # @param api [Crib::API] instance of API definition
    # @example
    #   class Client < Crib::Resource
    #     define 'https://api.github.com'
    #   end
    #   Client.new(Crib::API.new('https://api.github.dev')) # overrides above
    def initialize(api = nil)
      self.class._api = api if api
    end

    # @return [Crib::API] instance of API definition
    def api
      self.class._api
    end

    # @return [Sawyer::Response, nil] most recent response, if any
    def last_response
      api._last_response
    end

    # Defines an API for the Class
    #
    # @param endpoint [String] API endpoint
    # @param sawyer_options [Hash] options for Sawyer
    # @param block [Block] block for Sawyer
    # @example Define the GitHub API with HTTP header
    #   define 'https://api.github.com' do |c|
    #     c.headers[:user_agent] = 'crib'
    #   end
    def self.define(endpoint, sawyer_options = {}, &block)
      self._api = Crib::API.new(endpoint, sawyer_options, &block)
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

    # Makes a HTTP GET request
    #
    # @param request [Crib::Request] defined API request
    # @param options [Hash] query and header params for request
    # @return [Sawyer::Resource]
    def get(request, options = {})
      request.send(:_get, options)
    end

    # Makes a HTTP POST request
    #
    # @param request [Crib::Request] defined API request
    # @param data [Object] body for request
    # @param options [Hash] header params for request
    # @return [Sawyer::Resource]
    def post(request, data = nil, options = {})
      request.send(:_post, data, options)
    end

    # Makes a HTTP PUT request
    #
    # @param request [Crib::Request] defined API request
    # @param data [Object] body for request
    # @param options [Hash] header params for request
    # @return [Sawyer::Resource]
    def put(request, data = nil, options = {})
      request.send(:_put, data, options)
    end

    # Makes a HTTP PATCH request
    #
    # @param request [Crib::Request] defined API request
    # @param data [Object] body for request
    # @param options [Hash] header params for request
    # @return [Sawyer::Resource]
    def patch(request, data = nil, options = {})
      request.send(:_patch, data, options)
    end

    # Makes a HTTP DELETE request
    #
    # @param request [Crib::Request] defined API request
    # @param options [Hash] query and header params for request
    # @return [Sawyer::Resource]
    def delete(request, options = {})
      request.send(:_delete, options)
    end

    # Makes a HTTP HEAD request
    #
    # @param request [Crib::Request] defined API request
    # @param options [Hash] query and header params for request
    # @return [Sawyer::Resource]
    def head(request, options = {})
      request.send(:_head, options)
    end
  end
end
