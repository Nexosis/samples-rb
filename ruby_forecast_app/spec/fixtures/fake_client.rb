require 'sinatra/base'
require 'fixtures/fake_models'

class FakeClient < Sinatra::Base
  get '/v1/sessions' do
    json_response 200, 'session_list.json'
  end

  get '/v1/data' do
    page_size = params[:pageSize] || 1
    page_number = params[:page] || 0
    json_response(200, 'data_list.json')
    new_body = JSON.parse(body[0])
    new_body['pageSize'] = page_size.to_i
    new_body['page'] = page_number.to_i
    new_body['items'] = Array.new(page_size.to_i, fake_dataset('test_dataset'))
    body new_body.to_json
  end

  put '/v1/data/:dataset_name' do |name|
    status 200
    body ''
  end

  get '/v1/models' do
    json_response(200,'model_list.json')
  end

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    body File.open(File.dirname(__FILE__) + '/responses/' + file_name, 'rb').read
  end
end
