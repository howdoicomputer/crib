require 'sinatra/base'

class GitHub < Sinatra::Base
  get '/users/:username' do
    json_response 'users:rafalchmiel.json' if params[:username] == 'rafalchmiel'
  end

  get '/repos/rails/rails/issues' do
    if params[:per_page] == '2' &&
       env['HTTP_ACCEPT'] == 'application/vnd.github+json'
      json_response 'repos:rails:rails:issues?per_page=2.json'
    end
  end

  post '/markdown' do
    "<p><strong>test</strong></p>\n" if params[:text] == '**test**'
  end

  put('/ping') { 'true' }
  patch('/ping') { 'true' }
  delete('/ping') { 'true' }
  head('/ping') { 'true' }

  private

  def json_response(file)
    content_type :json
    status 200
    File.open(File.dirname(__FILE__) + '/fixtures/' + file, 'rb').read
  end
end
