module Crib
  # Handles the construction and execution of requests
  class Request
    # Header keys that can be passed in options hash to {#_get},{#_head}
    CONVENIENCE_HEADERS = Set.new([:accept, :content_type])

    # Defines a request
    #
    # @param api [Crib::API] API definition
    # @param uri [String] URI path
    def initialize(api, uri = '')
      @api, @uri = api, uri
    end

    # Make a HTTP GET request
    #
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def _get(options = {})
      request :get, @uri, parse_query_and_convenience_headers(options)
    end

    # Make a HTTP POST request
    #
    # @param options [Hash] Body and header params for request
    # @return [Sawyer::Resource]
    def _post(options = {})
      request :post, @uri, options
    end

    # Make a HTTP PUT request
    #
    # @param options [Hash] Body and header params for request
    # @return [Sawyer::Resource]
    def _put(options = {})
      request :put, @uri, options
    end

    # Make a HTTP PATCH request
    #
    # @param options [Hash] Body and header params for request
    # @return [Sawyer::Resource]
    def _patch(options = {})
      request :patch, @uri, options
    end

    # Make a HTTP DELETE request
    #
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def _delete(options = {})
      request :delete, @uri, options
    end

    # Make a HTTP HEAD request
    #
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def _head(options = {})
      request :head, @uri, parse_query_and_convenience_headers(options)
    end

    private

    attr_reader :api, :uri

    def request(method, uri, data, options = {})
      if data.is_a?(Hash)
        options[:query]   = data.delete(:query) || {}
        options[:headers] = data.delete(:headers) || {}
        if accept = data.delete(:accept)
          options[:headers][:accept] = accept
        end
      end

      @api._last_response = @api._agent.call(method, URI(uri), data, options)
      @api._last_response.data
    end

    def parse_query_and_convenience_headers(options)
      headers = options.fetch(:headers, {})
      CONVENIENCE_HEADERS.each do |h|
        if header = options.delete(h)
          headers[h] = header
        end
      end
      query, opts = options.delete(:query), { query: options }
      opts[:query].merge!(query) if query && query.is_a?(Hash)
      opts[:headers] = headers unless headers.empty?

      opts
    end

    def method_missing(method_name, *args)
      Request.new(api, Helpers.construct_uri(@uri, method_name, args))
    end
  end
end
