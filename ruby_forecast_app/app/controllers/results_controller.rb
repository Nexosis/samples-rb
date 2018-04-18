require 'nexosis_api'

class ResultsController < ApplicationController

  def index
    params.require(:session_id)
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
    Rails.cache.fetch("session-#{params[:session_id]}") do
      @session = @api_client.get_session params[:session_id]
    end
    @session_result = @api_client.get_session_results(params[:session_id])
    if !@session_result.nil? && !@datasets.nil? && !@session.nil?
      set_column_names
      is_dataset = @datasets.map(&:dataset_name).include? @session_result.datasource_name
      # TODO: cannot determine pages from API - need dataset information to be more specific
      if @session_result.type == 'forecast'
        # TODO: day basis assumption should be changed for evaluation of actual
        # This would require pulling some observations first or requesting the
        # basis from the user.
        obs_count = calc_day_interval(@session_result.result_interval, 30.0)
        page_size = 50
        page_size = obs_count unless obs_count < 30
        page_size = 1000 if page_size > 1000
        first_pred = DateTime.parse(@session_result.start_date)
        last_obs =  first_pred + calc_day_interval(@session_result.result_interval, 1.0)
        first_obs = first_pred - obs_count
        if is_dataset
          @observations = @api_client.get_dataset(
            @session_result.datasource_name,
            0,
            page_size.to_i,
            start_date: first_obs,
            end_date: last_obs
          )
        else
          @observations = @api_client.get_view(@session_result.datasource_name, 0, 30, {:start_date => first_obs, :end_date => last_obs})
        end
      else
        first_obs = DateTime.parse(@session_result.start_date) - 15
        last_obs = DateTime.parse(@session_result.end_date) + 15
        total_event_days = (DateTime.parse(@session_result.end_date) - DateTime.parse(@session_result.start_date)).to_i
        if is_dataset
          @observations = @api_client.get_dataset(
            @session_result.datasource_name,
            0,
            total_event_days + 30,
            start_date: first_obs,
            end_date: last_obs
          )
        else
          @observations = @api_client.get_view(
            @session_result.datasource_name,
            0,
            total_event_days + 30,
            start_date: first_obs,
            end_date: last_obs
          )
        end
      end
      # metadata does not always match the case of data hash keys
      @timestamp_column = @observations.data.first.keys.select{|k| k.downcase == @timestamp_column.downcase}.first
      observation_interval =
        get_observation_interval(
          @observations.data.map { |obs| DateTime.parse(obs[@timestamp_column]) }
        )
      target_interval = 'day' if @session_result.result_interval.nil? else @session_result.result_interval
      @observations.data = summarize_observations(observation_interval, @session_result.result_interval) if observation_interval != target_interval
      # HACK: need to make sure can reference target no matter how specified session, dataset, view
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
    end
  end

  def file
    params.require(:session_id)
    client = NexosisApi.client(Rails.application.secrets.api_key)
    @session_result = client.get_session_results(params[:session_id], true)
    filename = "#{params[:session_id]}.csv"
    response.headers['Content-Disposition'] = "attachment;filename=#{filename}"
    render inline: @session_result, content_type: 'text/csv'
  end

  def model
    params.require(:session_id)
    params.require(:model_id)
    model_output params['session_id']
    begin
      @model = @api_client.get_model params['model_id']
      @result_data = @session.data.map { |h| h.select { |k, _v| k == @session.target_column } }
      @actual = @session.data.map { |h| h.select { |k, _v| k.end_with? ':actual' } }
      render
    rescue NexosisApi::HttpException => ex_http
      @model = nil
      @message = ex_http.message
      @error_code = ex_http.code
    end
  end

  def model_output session_id
    Rails.cache.fetch("#{session_id}-results", expires_in: 5.minutes) do
      @session = @api_client.get_session_results params['session_id']
    end
    if (@session.prediction_domain == 'classification')
      Rails.cache.fetch("#{session_id}-confusionmatrix", expires_in: 5.minutes) do
        @class_results = @api_client.get_confusion_matrix(@session.session_id)
      end
      @matrix = @class_results.confusion_matrix.each_with_index.map do |arr, outer_index|
        arr.each_with_index.map do |value, inner_index|
          { value: value, color: get_color(arr.max, value, outer_index == inner_index) }
        end
      end
      acc ||= @session.metrics.select { |m| m.name == 'macroAverageF1Score' }.first
      acc ||= @session.metrics.select { |m| m.name == 'rocAreaUnderCurve' }.first
      @accuracy = "%.3f" % (acc.value * 100)
    end
  end

  def contest
    Rails.cache.fetch('account-quotas', expires_in: 5.minutes) do
      @quotas = @api_client.get_account_quotas
    end
    if @quotas['nexosis-account-datasetcount-allotted'][0].to_i <= 25
      @error_message = 'You must have a paid account plan to access contest results'
      return
    end
    Rails.cache.fetch("contest-results-#{params[:session_id]}") do
      @contest = @api_client.get_session_contest params[:session_id]
    end
  end

  def anomaly
    session_id = params[:session_id]
    page_size = 500
    Rails.cache.fetch("session-#{session_id}") do
      @session = @api_client.get_session session_id
    end
    Rails.cache.fetch("#{session_id}-results-#{page_size}", expires_in: 5.minutes) do
      @session_results = @api_client.get_session_result_data(params['session_id'], 0, page_size)
    end
    Rails.cache.fetch("anomaly-scores-#{session_id}", expires_in: 5.minutes) do
      begin
        scores = @api_client.get_anomaly_scores session_id, 0, 500
        @data_rows = scores.data.map { |d| d.reject { |k, _v| k == 'anomaly' }.values.map{ |v| v.to_f } }
        @anomalies = scores.data.map { |d| d.select { |k, _v| k == 'anomaly' || k == @session.target_column }.values.map{ |v| v.to_f } }.flatten
      rescue NexosisApi::HttpException => e
        @data = nil
        @message = e.message
      end
    end

    render
  end

  private
  def get_color(max, value, is_target)
    case ((value.to_r / max.to_r) * 100).to_i
    when 0
      return '#CABDBD' unless is_target
      '#F23131'
    when 1..33
      '#EFE975'
    when 34..65
      '#FFB01D'
    when 66..100
      return '#F23131' unless is_target
      '#2DB71D'
    else
      '#4CFFFC'
    end
  end

  def set_column_names
    @timestamp_column = @session.column_metadata.select { |dc|
      dc.role == NexosisApi::ColumnRole::TIMESTAMP
    }.first.name
    @target_column = @session.column_metadata.select { |dc|
      dc.role == NexosisApi::ColumnRole::TARGET
  }.first.name
  end

  def calc_day_interval(interval, periods)
    case interval
    when 'hour'
      periods / 24.0
    when 'week'
      periods * 7
    when 'month'
      periods * 31
    when 'year'
      periods * 365
    else
      periods
    end
  end

  def get_observation_interval(observations)
    # HACK: arbitrary to some extent. Best guess.
    # non time-series may not be sorted properly
    return @session.result_interval unless @observations.is_timeseries
    spacer = (observations[1] - observations[0]).to_f
    if spacer <= 0.5
      'hour'
    elsif spacer > 0.5 && spacer <= 2.0
      'day'
    elsif spacer > 2.0 && spacer <= 8.0
      'week'
    elsif spacer > 8.0 && spacer <= 33.0
      'month'
    else
      'year'
    end
  end

  def summarize_observations(current_interval, target_interval)
    grouping = get_observation_grouping(current_interval, target_interval)
    strategy = @session.column_metadata.find do |cm|
      cm.name == @target_column
    end.aggregation
    aggregation_algo = get_aggregation_algo(strategy)
    @observations.data
                 .map { |row| [DateTime.parse(row[@timestamp_column]) - grouping, row[@target_column].to_f] }
                 .each_slice(grouping).map { |a| a unless a.count < grouping }
                 .compact
                 .map { |values| { @timestamp_column => values[0][0], @target_column => aggregation_algo.call(values.map { |v| v[1] }) } }
  end

  def get_observation_grouping(current_interval, target_interval)
    current_interval = 'day' if current_interval.nil?
    case current_interval
    when 'hour'
      return 24 if target_interval == 'day'
      return 24 * 7 if target_interval == 'week'
    when 'day'
      return 7 if target_interval == 'week'
      return 30 if target_interval == 'month'
      return 365 if target_interval == 'year'
    when 'week'
      return 4 if target_interval == 'month'
      return 52 if target_interval == 'year'
    when 'month'
      12
    end
  end

  def get_aggregation_algo(strategy)
    case strategy
    when 'sum'
      ->(values) { values.reduce(:+) }
    when 'mean'
      ->(values) { values.reduce(:+) / values.count }
    when 'min'
      ->(values) { values.min }
    when 'max'
      ->(values) { values.max }
    end
  end
end
