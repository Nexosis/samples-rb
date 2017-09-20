require 'nexosis_api'

class ResultsController < ApplicationController

  def index
    params.require(:sessionId)
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
    
    @session_result = @api_client.get_session_results(params[:sessionId])
    if !@session_result.nil? && !@datasets.nil?
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
        first_pred = DateTime.parse(@session_result.startDate)
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
        first_obs = DateTime.parse(@session_result.startDate) - 15
        last_obs = DateTime.parse(@session_result.endDate) + 15
        total_event_days = (DateTime.parse(@session_result.endDate) - DateTime.parse(@session_result.startDate)).to_i
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
      observation_interval =
        get_observation_interval(
          @observations.data.map { |obs| DateTime.parse(obs[@timestamp_column]) }
        )
      @observations.data = summarize_observations(observation_interval, @session_result.result_interval) if observation_interval != @session_result.result_interval
      # HACK: need to make sure can reference target no matter how specified session, datasset, view
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
    params.require(:sessionId)
    client = NexosisApi.client(Rails.application.secrets.api_key)
    @session_result = client.get_session_results(params[:sessionId], true);
    filename = "#{params[:sessionId]}.csv"
    response.headers['Content-Disposition'] = "attachment;filename=#{filename}"
    render inline: @session_result, content_type: 'text/csv'
  end

  private
  def set_column_names
    @timestamp_column = @session_result.column_metadata.select { |dc|
      dc.role == NexosisApi::ColumnRole::TIMESTAMP
    }.take(1).first().name
    @target_column = @session_result.column_metadata.select { |dc|
      dc.role == NexosisApi::ColumnRole::TARGET
    }.take(1).first().name
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
    strategy = @session_result.column_metadata.find do |cm|
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
