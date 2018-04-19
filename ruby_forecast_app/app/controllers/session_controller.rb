class SessionController < ApplicationController
  def index
    params.permit(:page_size)
    params.permit(:page_number)
    page_size = params['page_size'] || 25
    page_number = params['page_number'] || 0
    Rails.cache.fetch("sessions-list_#{page_number}_#{page_size}", :expires_in => 2.minutes) do
      @sessions = @api_client.list_sessions NexosisApi::SessionListQuery.new(page_number: page_number, page_size: page_size, sort_by: 'requestedDate', sort_order: 'desc')
    end
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
    @page = page_number.to_i
    @page_size = page_size.to_i
  end

  def session_status
    params.require(:session_id)
    @session = @api_client.get_session(params['session_id'])
    Rails.cache.fetch('account-quotas', :expires_in => 5.minutes) do
      @quotas = @api_client.get_account_quotas
    end
    @is_paying = @quotas['nexosis-account-datasetcount-allotted'][0].to_i > 25
    render 'session'
  end
    
  def forecast
    params.require(:dataset_name)
    @dataset_name = params['dataset_name']
  end

  def create_forecast
    params.require(:dataset_name)
    params.require(:target_column)
    params.require(:start_date)
    params.require(:end_date)
    params.require(:interval)
    params.permit(:is_estimate)
    estimate_only = params['is_estimate'] == 'on' ? true : false
    begin
      if estimate_only
        @forecast_result = @api_client.estimate_forecast_session params['dataset_name'], params['start_date'], params['end_date'], params['target_column'], params['interval']
      else
        @forecast_result = @api_client.create_forecast_session params['dataset_name'], params['start_date'], params['end_date'], params['target_column'], params['interval']
      end
    rescue NexosisApi::HttpException => http_error
      @error = http_error
    end
    Rails.cache.delete 'sessions-list'
    render 'forecast'
  end

  def impact
    params.require(:dataset_name)
    @dataset_name = params['dataset_name']
  end
  
  def create_impact
    params.require(:dataset_name)
    params.require(:target_column)
    params.require(:start_date)
    params.require(:end_date)
    params.require(:event_name)
    params.require(:interval)
    params.permit(:is_estimate)
    estimate_only = params['is_estimate'] == 'on' ? true : false
    @event_name = params['event_name']
    begin
      if(estimate_only)
        @impact_result = @api_client.estimate_impact_session(params['dataset_name'], params['start_date'], params['end_date'] , params['event_name'], params['target_column'], params['interval'])
      else
        @impact_result = @api_client.create_impact_session(params['dataset_name'], params['start_date'], params['end_date'] , params['event_name'], params['target_column'], params['interval'])
      end
    rescue NexosisApi::HttpException => http_error
      @error = http_error
    end
    Rails.cache.delete 'sessions-list'
    render 'impact'
  end

  def delete
    params.require(:session_id)
    @api_client.remove_session params['session_id']
    Rails.cache.delete 'sessions-list'
    redirect_to action: 'index'
  end

  def model
    params.require(:dataset_name)
    params.permit(:dataset_name)
    @dataset_name = params['dataset_name']
    render
  end

  def create_model
    params.permit(:dataset_name)
    params.permit(:target_column)
    params.permit(:prediction_domain)
    params.permit(:balance)
    Rails.cache.delete 'model-list'
    Rails.cache.delete 'sessions-list'
    options = { prediction_domain: params['prediction_domain'] }
    if params['prediction_domain'] == 'Classification' && params[:balance].nil?
      options.store(:balance, false)
    end
    
    session = @api_client.create_model params['dataset_name'],
                                       params['target_column'],
                                       {},
                                       options
    redirect_to action: 'session_status', session_id: session.session_id
  end
end
