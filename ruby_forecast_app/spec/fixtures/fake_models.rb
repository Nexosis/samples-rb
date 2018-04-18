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