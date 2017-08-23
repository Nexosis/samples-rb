require 'nexosis_api'

class ResultsController < ApplicationController

  def index
    params.require(:sessionId)
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
    
    @sessionResult = @api_client.get_session_results(params[:sessionId]);
    is_dataset = @datasets.map(&:dataset_name).include? @sessionResult.datasource_name
    #TODO: cannot determine pages from API - need dataset information to be more specific
    if @sessionResult.type == "forecast"
      #timestamp_col = @sessionResult.column_metadata.select{|dc| dc.role == NexosisApi::ColumnRole::TIMESTAMP}.take(1).first().name
      firstPred = Date.parse(@sessionResult.startDate)
      lastObs =  firstPred - calc_day_interval(@sessionResult.result_interval,1)
      firstObs = firstPred - calc_day_interval(@sessionResult.result_interval,30)
      if is_dataset
        @observations = @api_client.get_dataset(@sessionResult.datasource_name, 0, 30, {:start_date => firstObs, :end_date => lastObs})
      else
        @observations = @api_client.get_view(@sessionResult.datasource_name, 0, 30, {:start_date => firstObs, :end_date => lastObs})
      end
    else
      firstObs = Date.parse(@sessionResult.startDate) - 15
      lastObs = Date.parse(@sessionResult.endDate) + 15
      totalEventDays = (Date.parse(@sessionResult.endDate) - Date.parse(@sessionResult.startDate)).to_i
      if is_dataset
        @observations = @api_client.get_dataset(@sessionResult.datasource_name, 0, totalEventDays + 30, {:start_date => firstObs, :end_date => lastObs})
      else
        @observations = @api_client.get_view(@sessionResult.datasource_name, 0, totalEventDays + 30, {:start_date => firstObs, :end_date => lastObs})
      end
    end
    arr = []
    #HACK: need to make sure can reference target no matter how specified session, datasset, view
    @observations.data.each do |data_hash|
      new_hash = {}
      data_hash.each { |k, v| new_hash.store k.downcase, v }
      arr << new_hash
    end
    @observations.data = arr
    render
  end

  def file
    params.require(:sessionId)
    client = NexosisApi.client(Rails.application.secrets.api_key)
    @sessionResult = client.get_session_results(params[:sessionId], true);
    filename = "#{params[:sessionId]}.csv"
    response.headers['Content-Disposition'] = "attachment;filename=#{filename}"
    render inline: @sessionResult, content_type: 'text/csv'
  end

  private
  def calc_day_interval(interval, periods)
    case interval
    when "week"
      periods * 7
    when "month"
      periods * 31
    when "year"
      periods * 365
    else
     periods
    end
  end
end
