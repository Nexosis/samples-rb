require 'rails_helper'
require 'fixtures/fake_models'

RSpec.describe 'dataset/index', type: :view do
  before(:each) do
    assign(:page, 0)
    assign(:page_size,25)
    assign(:datasets,
      NexosisApi::PagedArray.new(
        {
          'pageNumber' => 0,
          'totalPages' => 2,
          'pageSize' => 10,
          'totalCount' => 20
        },
        [
          fake_dataset('test_dataset')
        ]
      )
    )
  end

  it 'renders a list of datasets' do
    render
    expect(rendered).to match(%r{\/sessions\/model\/test_dataset})
  end
end
