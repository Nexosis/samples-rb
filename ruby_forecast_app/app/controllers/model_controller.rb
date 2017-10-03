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

  end
end
