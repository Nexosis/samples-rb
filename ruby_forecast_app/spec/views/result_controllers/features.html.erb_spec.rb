require 'rails_helper'
require 'fixtures/fake_models'

RSpec.describe 'results/features', type: :view do
  before(:each) do
    assign(:page, 0)
    assign(:page_size, 10)
  end
  it 'renders a table of feature scores' do
    assign(:feature_results, fake_feature_scores)
    render
    expect(rendered).to match(%r{Feature Scores})
  end

  describe 'with no results' do
    it 'returns a not found message' do
      assign(:feature_results, nil)
      render
      expect(rendered).to match(/No feature importance scores could be found for this session/)
    end
  end
end
