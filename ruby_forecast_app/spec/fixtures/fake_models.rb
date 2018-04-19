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