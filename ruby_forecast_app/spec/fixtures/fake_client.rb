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
    ds_item = new_body['items'][0]
    new_body['pageSize'] = page_size.to_i
    new_body['page'] = page_number.to_i
    new_body['items'] = Array.new(page_size.to_i, ds_item)
    body new_body.to_json
  end

  get '/v1/data/:dataset_name' do |name|
    return json_response 200, 'timeseries_dataset.json' if name == 'Location-A'
    json_response 200, 'dataset.json'
  end

  put '/v1/data/:dataset_name' do |name|
    status 200
    body ''
  end

  get '/v1/models' do
    json_response(200, 'model_list.json')
  end

  get '/v1/imports' do
    json_response(200, 'import_list.json')
  end

  get '/v1/sessions/:session_id' do |id|
    if id == '0162b017-328b-48b7-abcb-70406b3f480e'
      json_response(200, 'timeseries_session.json')
    else
      json_response(200, 'session.json')
    end
  end

  get '/v1/sessions/:session_id/results' do |id|
    if id == '0162b017-328b-48b7-abcb-70406b3f480e'
      json_response(200, 'timeseries_session_results.json')
    else
      json_response(200, 'session_results.json')
    end
  end

  get '/v1/sessions/:session_id/results/featureimportance' do |id|
    json_response(200, 'feature_importance.json')
  end
  def json_response(response_code, file_name)
    content_type :json
    status response_code
    body File.open(File.dirname(__FILE__) + '/responses/' + file_name, 'rb').read
  end
end
