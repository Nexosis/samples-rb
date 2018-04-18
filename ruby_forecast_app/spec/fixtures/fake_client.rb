require 'sinatra/base'

class FakeClient < Sinatra::Base
  get '/v1/sessions' do
    json_response 200, 'session_list.json'
  end

  get '/v1/data' do
    json_response 200, 'data_list.json'
  end

  put '/v1/data/:dataset_name' do |name|
    status 200
    body ''
  end

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/responses/' + file_name, 'rb').read
  end
end
