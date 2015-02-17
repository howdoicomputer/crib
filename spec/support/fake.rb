require 'sinatra/base'

class Fake < Sinatra::Base
  [:get, :post, :put, :patch, :delete, :head].each do |verb|
    send(verb, '/ping/?:id') do
      content_type :json
      {
        params: params,
        body: request.body.read,
        headers: {
          accept: request.env['HTTP_ACCEPT']
        },
        url: request.url
      }.to_json
    end
  end
end
