class ViewController < ApplicationController
  def index
    params.permit(:error)
    @error = params[:error]
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
    Rails.cache.fetch('views_list') do
      @views = @api_client.list_views
    end
  end

  def detail
    params.require(:view_name)
    params.permit(:with_data)
    params.permit(:page)
    vw_name = params['view_name']
    @page = 0
    if(params['with_data'])
      @page = params['page'].to_i unless params['page'].nil?
      page_size = 20
      Rails.cache.fetch("viewdata-#{vw_name}-#{@page}", :expires_in => 2.minutes) do
        @view_data = @api_client.get_view vw_name, params['page'], page_size
      end
      @rowcount = @view_data.data.length
      
    end
    Rails.cache.fetch("view-#{vw_name}", :expires_in => 2.minutes) do
      result = @api_client.list_views vw_name
      @view = result.first unless result.empty?
    end
  end

  def update
    params.require(:view_name)
    params.require(:role)
    params.require(:datatype)
    params.require(:imputation)
    params.require(:aggregation)
    params.require(:column)
    parameter_hash = params.to_unsafe_h
    vw_name = params['view_name']
    Rails.cache.fetch("view-#{vw_name}", :expires_in => 2.minutes) do
      result = @api_client.list_views vw_name
      @view = result.first unless result.empty?
    end

    @view.column_metadata = parameter_hash['column'].map do |index, column|
      details = {}
      details.store 'datatype', parameter_hash['datatype'][index]
      details.store 'role', parameter_hash['role'][index]
      details.store 'imputation', parameter_hash['imputation'][index]
      details.store 'aggregation', parameter_hash['aggregation'][index]
      NexosisApi::Column.new(column, details)
    end

    Rails.cache.delete("view-#{vw_name}")
    @api_client.create_view_by_def @view
    redirect_to action: 'detail', dataset_name: vw_name
  end

  def delete
		params.require(:view_name)
		begin
			@api_client.remove_view(params["view_name"].downcase)
    rescue NexosisApi::HttpException => http_error
      @action = "Attepting to delete the view #{params['view_name']}."
      @error = http_error
      render 'shared/error'
      return
    end
    Rails.cache.delete('views_list')
		redirect_to action: 'index'
  end
  
  def create
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
  end

  def create_view
    params.require(:view_name)
    params.require(:dataset_name)
    params.require(:join_dataset_name)
    begin
    @api_client.create_view(params['view_name'],
                            params['dataset_name'],
                            params['join_dataset_name'])
    rescue NexosisApi::HttpException => http_error
      @action = "Attepting to create the view #{params['view_name']}."
      @error = http_error
      render 'shared/error'
      return
    end
    Rails.cache.delete('dataset_list')
    redirect_to :index
  end
end
