require 'nexosis_api'

class ResultsController < ApplicationController

  def index
    params.require(:sessionId)
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
    
    @session_result = @api_client.get_session_results(params[:sessionId]);
    is_dataset = @datasets.map(&:dataset_name).include? @session_result.datasource_name
    #TODO: cannot determine pages from API - need dataset information to be more specific
    if @session_result.type == "forecast"
      #timestamp_col = @session_result.column_metadata.select{|dc| dc.role == NexosisApi::ColumnRole::TIMESTAMP}.take(1).first().name
      firstPred = Date.parse(@session_result.startDate)
      lastObs =  firstPred - calc_day_interval(@session_result.result_interval,1)
      firstObs = firstPred - calc_day_interval(@session_result.result_interval,30)
      if is_dataset
        @observations = @api_client.get_dataset(@session_result.datasource_name, 0, 30, {:start_date => firstObs, :end_date => lastObs})
      else
        @observations = @api_client.get_view(@session_result.datasource_name, 0, 30, {:start_date => firstObs, :end_date => lastObs})
      end
    else
      firstObs = Date.parse(@session_result.startDate) - 15
      lastObs = Date.parse(@session_result.endDate) + 15
      totalEventDays = (Date.parse(@session_result.endDate) - Date.parse(@session_result.startDate)).to_i
      if is_dataset
        @observations = @api_client.get_dataset(@session_result.datasource_name, 0, totalEventDays + 30, {:start_date => firstObs, :end_date => lastObs})
      else
        @observations = @api_client.get_view(@session_result.datasource_name, 0, totalEventDays + 30, {:start_date => firstObs, :end_date => lastObs})
      end
    end
    #HACK: need to make sure can reference target no matter how specified session, datasset, view
    @observations.data = @observations.data.map do |data_hash|
      new_hash = {}
      data_hash.each { |k, v| new_hash.store k.downcase, v }
      new_hash
    end
    @session_result.data = @session_result.data.map do |data_hash|
      new_hash = {}
      data_hash.each { |k, v| new_hash.store k.downcase, v }
      new_hash
    end
    render
  end

  def file
    params.require(:sessionId)
    client = NexosisApi.client(Rails.application.secrets.api_key)
    @session_result = client.get_session_results(params[:sessionId], true);
    filename = "#{params[:sessionId]}.csv"
    response.headers['Content-Disposition'] = "attachment;filename=#{filename}"
    render inline: @session_result, content_type: 'text/csv'
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
