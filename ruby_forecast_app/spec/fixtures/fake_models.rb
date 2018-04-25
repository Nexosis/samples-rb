def fake_dataset(dataset_name)
  NexosisApi::DatasetSummary.new(
    {
      'dataSetName' => dataset_name,
      'columns' => {
        'sales' => {
          'dataType' => 'numericMeasure',
          'role' => 'feature',
          'imputation' => 'mean',
          'aggregation' => 'mean'
        }
      }
    }
  )
end

def fake_dataset_list(page_size, page_number)
  datalist_hash = JSON.parse(File.open(File.dirname(__FILE__) + '/responses/data_list.json', 'rb').read)
  datalist_hash['pageNumber'] = page_number
  datalist_hash['pageSize'] = page_size
  items = Array.new(page_size.to_i, fake_dataset('fake_dataset'))
  NexosisApi::PagedArray.new(datalist_hash, items)
end

def fake_feature_scores
  NexosisApi::FeatureImportance.new(
    {
      'featureImportance' => {
        'col1': 1,
        'col2': 0.9
      },
      'predictionDomain': 'regression',
      'name': 'Regression on mpg-missing',
      'dataSourceName': 'mpg-missing',
      'sessionId': '0162cfce-1ecc-4733-aaa4-02db0ce799d2',
      'modelId': 'd09d6460-80e7-4d1f-8652-fb4f98e0dc36',
      'pageNumber': 0,
      'totalPages': 4,
      'pageSize': 100,
      'totalCount': 351
    }
  )
end
