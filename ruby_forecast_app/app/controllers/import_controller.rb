class ImportController < ApplicationController
  def index
    Rails.cache.fetch('import-list', expires_in: 3.minutes) do
      @imports = @api_client.list_imports
    end
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
  end

  def detail
    params.require(:import_id)
    @import = @api_client.retrieve_import params['import_id']
  end
end