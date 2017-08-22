class SessionController < ApplicationController
  def index
    Rails.cache.fetch('sessions-list', :expires_in => 2.minutes) do
      @sessions = @api_client.list_sessions
    end
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
    render
  end

  def session_status
    params.require(:session_id)
    @session = @api_client.get_session(params['session_id'])
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
end