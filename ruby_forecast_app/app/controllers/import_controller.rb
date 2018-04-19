class ImportController < ApplicationController
  def index
    params.permit(:page_size)
    params.permit(:page_number)
    page_size = params['page_size'] || 25
    page_number = params['page_number'] || 0
    Rails.cache.fetch("import-list_#{page_size}_#{page_number}", expires_in: 3.minutes) do
      @imports = @api_client.list_imports NexosisApi::ImportListQuery.new(page_size: page_size, page_number: page_number, sort_by: 'requestedDate', sort_order: 'desc')
    end
    Rails.cache.fetch('dataset_list') do
      @datasets = @api_client.list_datasets
    end
    @page = page_number.to_i
    @page_size = page_size.to_i
  end

  def detail
    params.require(:import_id)
    @import = @api_client.retrieve_import params['import_id']
  end
end