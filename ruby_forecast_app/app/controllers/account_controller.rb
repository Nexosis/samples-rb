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
			@datasets = @api_client.list_datasets
		rescue NexosisApi::HttpException => http_error
			@error = http_error
		end
		render
	end

	def sessions
		@sessions = @api_client.list_sessions
		render
	end

	def session_status
		params.require(:session_id)
		@session = @api_client.get_session(params["session_id"])
		render "session"
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

	def forecast
		params.require(:dataset_name)
		@dataset_name = params["dataset_name"]
	end

	def create_forecast
		params.require(:dataset_name)
		params.require(:target_column)
		params.require(:start_date)
		params.require(:end_date)
		params.require(:interval)
		params.permit(:is_estimate)
		estimate_only = params["is_estimate"] == "on" ? true : false
		begin
			if(estimate_only)		
				@forecast_result = @api_client.estimate_forecast_session params["dataset_name"], params["start_date"], params["end_date"], params["target_column"], params["interval"]
			else	
				@forecast_result = @api_client.create_forecast_session params["dataset_name"], params["start_date"], params["end_date"], params["target_column"], params["interval"]
			end
		rescue NexosisApi::HttpException => http_error
			@error = http_error
		end
		render "forecast"
	end

	def impact
		params.require(:dataset_name)
		@dataset_name = params["dataset_name"]
	end
	
	def create_impact
		params.require(:dataset_name)
		params.require(:target_column)
		params.require(:start_date)
		params.require(:end_date)
		params.require(:event_name)
		params.require(:interval)
		params.permit(:is_estimate)
		estimate_only = params["is_estimate"] == "on" ? true : false
		@event_name = params["event_name"]
		begin
			if(estimate_only)
				@impact_result = @api_client.estimate_impact_session(params["dataset_name"], params["start_date"], params["end_date"] , params["event_name"], params["target_column"], params["interval"])
			else
				@impact_result = @api_client.create_impact_session(params["dataset_name"], params["start_date"], params["end_date"] , params["event_name"], params["target_column"], params["interval"])
			end
		rescue NexosisApi::HttpException => http_error
			@error = http_error
		end
		render "impact"
	end
	
end

