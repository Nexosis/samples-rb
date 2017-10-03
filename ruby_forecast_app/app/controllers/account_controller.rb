require 'nexosis_api'
require 'csv'

class AccountController < ApplicationController
  def index
    params.permit(:uploaded)
    if (params['uploaded'])
      @upload_message = 'Your dataset has been uploaded. If you used S3 it may take a few minutes before you see the dataset below.'
    end
    begin
      @account_balance = @api_client.get_account_balance
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
    use_s3 = params['fileLocation'] == 'S3'
    dataset_name = params['dataset_name']
    if (use_s3)
      bucket = params['bucket']
      path = params['path']
      region = params['region']
      @api_client.import_from_s3(dataset_name, bucket, path, region)
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
    redirect_to action: 'index', :uploaded => true
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
end
