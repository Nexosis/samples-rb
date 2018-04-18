require 'nexosis_api'
# Provide overview of metadata and opportunity to list data.
class DatasetController < ApplicationController
  def index
    params.permit(:page_size)
    params.permit(:page_number)
    page_size = params['page_size'] || 25
    page_number = params['page_number'] || 0
    Rails.cache.fetch("dataset_list_#{page_size}_#{page_number}") do
      @datasets = @api_client.list_datasets(
        NexosisApi::DatasetListQuery.new(page_size: page_size, page_number: page_number, sort_by: 'lastModified', sort_order: 'desc'))
    end
    @page = page_number.to_i
    @page_size = page_size.to_i
  end

  def detail
    params.require(:dataset_name)
    params.permit(:with_data)
    params.permit(:page)
    ds_name = params['dataset_name']
    @page = 0
    if(params['with_data'])
      @page = params['page'].to_i unless params['page'].nil?
      page_size = 20
      Rails.cache.fetch("datasetdata-#{ds_name}-#{@page}", :expires_in => 2.minutes) do
        @dataset_data = @api_client.get_dataset ds_name, params['page'], page_size
      end
      @rowcount = @dataset_data.data.item_total
      
    end
    Rails.cache.fetch("dataset-#{ds_name}", :expires_in => 2.minutes) do
      result = @api_client.list_datasets NexosisApi::DatasetListQuery.new({ partial_name: ds_name })
      @dataset = result.first unless result.empty?
    end
  end

  def update
    params.require(:dataset_name)
    params.require(:role)
    params.require(:datatype)
    params.require(:imputation)
    params.require(:aggregation)
    params.require(:column)
    parameter_hash = params.to_unsafe_h
    columns = { 'columns' => {} }
    parameter_hash['column'].each do |index, column|
      columns['columns'][column] = {}
      columns['columns'][column].store('dataType', parameter_hash['datatype'][index])
      columns['columns'][column].store('role', parameter_hash['role'][index])
      columns['columns'][column].store('imputation', parameter_hash['imputation'][index])
      columns['columns'][column].store('aggregation', parameter_hash['aggregation'][index])
    end
    ds_name = params['dataset_name']
    Rails.cache.delete("dataset-#{ds_name}")
    @api_client.create_dataset_json(ds_name, columns)
    redirect_to action: 'detail', dataset_name: ds_name
  end

  def delete
		params.require(:dataset_name)
		begin
			@api_client.remove_dataset(params['dataset_name'],{cascade: true})
		rescue NexosisApi::HttpException => http_error
			@error = http_error
    end
    Rails.cache.delete('dataset_list')
		redirect_to action: 'index'
	end
end
