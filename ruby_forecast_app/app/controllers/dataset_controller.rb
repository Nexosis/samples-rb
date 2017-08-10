require 'nexosis_api'
# Provide overview of metadata and opportunity to list data.
class DatasetController < ApplicationController
  def index
    @datasets = @api_client.list_datasets
  end

  def detail
    params.require(:dataset_name)
    result = @api_client.list_datasets params['dataset_name']
    @dataset = result.first unless result.empty?
  end

  def update
    params.require(:dataset_name)
    params.require(:role)
    params.require(:datatype)
    params.require(:imputation)
    params.require(:aggregation)
    columns = {'columns' => {}}
    #@api_client.create_dataset_json(params['dataset_name'], columns.to_json)
    redirect_to action: 'detail', dataset_name: params['dataset_name']
  end
end
