class ModelController < ApplicationController
  def index
    Rails.cache.fetch('model-list', expires_in: 3.minutes) do
      @models = @api_client.list_models
    end
  end

  def model
    params.permit(:model_id)
    params.require(:model_id)
    Rails.cache.fetch("model-detail-#{params['model_id']}", expires_in: 3.minutes) do
      begin
        @model = @api_client.get_model params['model_id']
      rescue NexosisApi::HttpException => ex_http
        @model = nil
        @message = ex_http.message
        @error_code = ex_http.code
      end
    end
  end

  def delete
    params.permit(:model_id)
    params.require(:model_id)
    Rails.cache.delete("model-detail-#{params['model_id']}")
    @api_client.remove_model params['model_id']
    redirect_to action: 'index'
  end

  def predict
    params.permit(:model_id)
    params.require(:model_id)
    Rails.cache.fetch("model-detail-#{params['model_id']}", expires_in: 3.minutes) do
      begin
        @model = @api_client.get_model params['model_id']
      rescue NexosisApi::HttpException => ex_http
        @model = nil
        @message = ex_http.message
        @error_code = ex_http.code
      end
    end
  end

  def upload
    params.permit(:datafile)
    params.permit(:model_id)
    uploaded_io = params['datafile']
    Rails.cache.fetch("model-detail-#{params['model_id']}", expires_in: 3.minutes) do
      @model = @api_client.get_model params['model_id']
    end
    @target = @model.column_metadata.select{|col| col.role == :target}.first.name
    begin
      json = JSON.parse(uploaded_io.read)
      @response = @api_client.predict params['model_id'], json
      @predictions = @response.predictions
    rescue StandardError => excep
      @message = excep.message
    end
    render 'results'
  end

  def results
    params.require(:data)
    #@predictions = params['data']
  end

end
