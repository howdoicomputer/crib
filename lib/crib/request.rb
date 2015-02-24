module Crib
  # Handles the construction and execution of requests
  class Request
    # @return [Set] passable header keys in options Hash to {#_get},{#_head}
    CONVENIENCE_HEADERS = Set.new([:accept, :content_type])

    # Defines a request
    #
    # @param api [Crib::API] API definition
    # @param path [String] REST path
    def initialize(api, path = '')
      @api  = api
      @path = path
    end

    # Makes a HTTP GET request
    #
    # @param options [Hash] query and header params for request
    # @return [Sawyer::Resource]
    def _get(options = {})
      request :get, @path, parse_query_and_convenience_headers(options)
    end

    # Makes a HTTP POST request
    #
    # @param data [Object] body for request
    # @param options [Hash] header params for request
    # @return [Sawyer::Resource]
    def _post(data = nil, options = {})
      request :post, @path, data, options
    end

    # Makes a HTTP PUT request
    #
    # @param data [Object] body for request
    # @param options [Hash] header params for request
    # @return [Sawyer::Resource]
    def _put(data = nil, options = {})
      request :put, @path, data, options
    end

    # Makes a HTTP PATCH request
    #
    # @param data [Object] body for request
    # @param options [Hash] header params for request
    # @return [Sawyer::Resource]
    def _patch(data = nil, options = {})
      request :patch, @path, data, options
    end

    # Makes a HTTP DELETE request
    #
    # @param options [Hash] query and header params for request
    # @return [Sawyer::Resource]
    def _delete(options = {})
      request :delete, @path, options
    end

    # Makes a HTTP HEAD request
    #
    # @param options [Hash] query and header params for request
    # @return [Sawyer::Resource]
    def _head(options = {})
      request :head, @path, parse_query_and_convenience_headers(options)
    end

    private

    attr_reader :api, :path

    def request(method, path, data, options = {})
      if data.is_a?(Hash)
        options[:query]   = data.delete(:query) || {}
        options[:headers] = data.delete(:headers) || {}
        if accept = data.delete(:accept)
          options[:headers][:accept] = accept
        end
      end

      @api._last_response = @api._agent.call(method, URI(path), data, options)
      @api._last_response.data
    end

    def parse_query_and_convenience_headers(options)
      headers = options.fetch(:headers) { {} }
      CONVENIENCE_HEADERS.each do |h|
        headers[h] = options.delete(h) if options[h]
      end
      query = options.delete(:query)
      opts  = { query: options }
      opts[:query].merge!(query) if query && query.is_a?(Hash)
      opts[:headers] = headers unless headers.empty?

      opts
    end

    def method_missing(method_name, *args)
      Request.new(api, Helpers.construct_path(@path, method_name, args))
    end
  end
end
