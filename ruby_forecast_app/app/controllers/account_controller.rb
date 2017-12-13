require 'nexosis_api'
require 'csv'

class AccountController < ApplicationController
  def index
    params.permit(:uploaded)
    params.permit(:method)
    if (params['uploaded'])
      if params['method'] == 'localfile'
        @upload_message = 'Your dataset has been uploaded.'
      else
        @upload_message = "Your file upload from #{params['method']} has been requested. Your dataset should be uploaded soon."
      end
    end
    begin
      @quota_balance = quota_hash(@api_client.get_account_quotas)
    rescue NexosisApi::HttpException => http_error
      @error = http_error
    end
    render
  end

  def upload
    params.require(:fileLocation)
    params.require(:dataset_name)
    params.permit(:bucket)
    params.permit(:path)
    params.permit(:region)
    params.permit(:datafile)
    params.permit(:azconnstring)
    params.permit(:azcontainer)
    params.permit(:blobpath)
    params.permit(:fileurl)
    use_s3 = params['fileLocation'] == 'S3'
    use_url = params['fileLocation'] == 'url'
    use_azure = params['fileLocation'] == 'azure'
    dataset_name = params['dataset_name']
    method = 'localfile'
    if use_s3
      method = 's3'
      bucket = params['bucket']
      path = params['path']
      region = params['region']
      @api_client.import_from_s3(dataset_name, bucket, path, region)
    elsif use_url
      method = 'url'
      url = params['fileurl']
      @api_client.import_from_url(dataset_name, url)
    elsif use_azure
      method = 'azure'
      connection_string = params['azconnstring']
      blob_name = params['blobpath']
      container = params['azcontainer']
      @api_client.import_from_azure(dataset_name, connection_string, container, blob_name)
    else
      uploaded_io = params['datafile']
      File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      is_csv = uploaded_io.original_filename.end_with?('csv')
      location = Rails.root.join('public', 'uploads',
                                 uploaded_io.original_filename)
      begin
        upload_csv(dataset_name, location) if is_csv
        upload_json(dataset_name, location) unless is_csv
      rescue NexosisApi::HttpException => http_error
        @error_message = http_error.message
        render
        return
      end
    end
    redirect_to action: 'index', :uploaded => true, method: method
  end

  private

  # @private
  def upload_csv(dataset_name, location)
    csv = CSV.open(location,
                   'rb',
                   headers: true)
    @api_client.create_dataset_csv(dataset_name, csv)
  end

  # @private
  def upload_json(dataset_name, location)
    json = JSON.parse(File.read(location))
    @api_client.create_dataset_json(dataset_name, json)
  end

  def quota_hash(headers)
    arr = headers.map do |k, v|
      { k.sub(/nexosis-account-(?<name>[a-z]+)count-current/, '\k<name>s').capitalize => v}.flatten
    end
    arr.to_h
  end
end
