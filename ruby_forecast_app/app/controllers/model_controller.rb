class ModelController < ApplicationController
  def index
    params.permit(:page_size)
    params.permit(:page_number)
    page_size = params['page_size'] || 25
    page_number = params['page_number'] || 0
    Rails.cache.fetch("model-list_#{page_size}_#{page_number}", expires_in: 3.minutes) do
      @models = @api_client.list_models NexosisApi::ModelListQuery.new(page_size: page_size, page_number: page_number, sort_by: 'lastUsedDate', sort_order: 'desc')
    end
    @page = page_number.to_i
    @page_size = page_size.to_i
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
    begin
      json = JSON.parse(uploaded_io.read)
      do_prediction params['model_id'], json
    rescue StandardError => excep
      @message = excep.message
    end
    render 'results'
  end

  def prediction
    params.require(:model_id)
    model_id = params['model_id']
    Rails.cache.fetch("model-detail-#{model_id}", expires_in: 3.minutes) do
      @model = @api_client.get_model model_id
    end
    values = @model.column_metadata.select { |c| c.role == :feature }.map { |col| [col.name, params[col.name]] }
    json = [values.to_h].to_json
    do_prediction params['model_id'], JSON.parse(json)
    render 'results'
  end

  private

  def do_prediction model_id, json
    Rails.cache.fetch("model-detail-#{model_id}", expires_in: 3.minutes) do
      @model = @api_client.get_model model_id
    end
    @target = @model.column_metadata.select { |col| col.role == :target }.first.name
    begin
      @response = @api_client.predict model_id, json
      @predictions = @response.predictions
    rescue StandardError => excep
      @message = excep.message
    end
  end

end
