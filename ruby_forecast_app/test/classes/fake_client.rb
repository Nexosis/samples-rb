class FakeClient
    def get_account_balance()
        "18.00 USD"
    end

    def create_dataset_json(dataset_name, json_data)
    end

    def create_dataset_csv(dataset_name, csv)
    end

    def list_datasets(partial_name = '')
        [] << NexosisApi::DatasetSummary.new({"dataSetName" => "TestData"})
    end

    def get_dataset(dataset_name, page_number = 0, page_size = 50, query_options = {}) 
    end

    def get_dataset_csv(dataset_name, page_number = 0, page_size = 50, query_options = {})
    end

    def remove_dataset(dataset_name, filter_options = {})
    end
    
    def list_sessions(query_options = {})
        [] << NexosisApi::SessionResponse.new(
                { "nexosis-account-balance" => ["6548.25"],
                    "nexosis-request-cost"=>["15.00"],
                    "session" => {
                        "sessionId" => "015ca6f7-ca42-49de-9601-f5493a03cbfa",
                        "type"=> "forecast",
                        "status" => "completed",
                        "requestedDate" => "2017-06-14T14:17:56.012548+00:00",
                        "statusHistory" => [
                            {
                                "date"=>"2017-06-14T14:17:56.012548+00:00",
                                "status"=>"requested"
                            },
                            {
                                "date"=>"2017-06-14T14:17:57.0034498+00:00",
                                "status"=>"started"
                            },
                            {
                                "date"=>"2017-06-14T14:18:05.1763039+00:00",
                                "status"=>"completed"
                            }],
                            "extraParameters" => {},
                            "columns" => {},
                            "dataSetName"=>"RubyTest",
                            "targetColumn"=>"sales",
                            "startDate"=>"2017-01-22T00:00:00+00:00",
                            "endDate"=>"2017-02-22T00:00:00+00:00",
                            "callbackUrl"=> "",
                            "isEstimate"=> false,
                            "resultInterval"=>nil}})
    end

    def remove_session(session_id)
    end

    def remove_sessions(query_options = {})
    end

    def create_forecast_session(dataset_name, start_date, end_date, target_column = nil)
    end

    def create_forecast_session_csv(csv, start_date, end_date, target_column)
    end

    def create_forecast_session_data(json_data, start_date, end_date, target_column = nil)
    end

    def estimate_forecast_session(dataset_name, start_date, end_date, target_column = nil)
    end

    def create_impact_session(dataset_name, start_date, end_date, event_name, target_column = nil)
    end

    def create_impact_session_data(json_data, start_date, end_date, event_name, target_column = nil)
    end

    def estimate_impact_session(dataset_name, start_date, end_date, event_name, target_column = nil)
    end

    def get_session_results(session_id, as_csv = false)
      NexosisApi::SessionResult.new({})
    end

    def get_session(session_id)
    end
end
