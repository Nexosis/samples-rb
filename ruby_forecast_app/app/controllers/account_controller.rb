require 'nexosis_api'
require 'csv'

class AccountController < ApplicationController
	def index
		params.permit(:uploaded)
		if(params["uploaded"])
			@uploadMessage = "Your dataset has been uploaded. If you used S3 it may take a few minutes before you see the dataset below."
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
		useS3 = params["fileLocation"] == "S3"
		dataset_name = params["dataset_name"]
		if(useS3)
			bucket = params["bucket"]
			path = params["path"]
			region = params["region"]
			@api_client.import_from_s3(dataset_name,bucket,path,region)
		else
			uploaded_io = params["datafile"]
			File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
				file.write(uploaded_io.read)
			end
			csv = CSV.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'rb', headers: true)
			begin
				@api_client.create_dataset_csv(dataset_name, csv)
			rescue NexosisApi::HttpException => http_error
				@error_message = http_error.message
				render
				return
			end
		end
		redirect_to action: 'index', :uploaded => true
	end
end

