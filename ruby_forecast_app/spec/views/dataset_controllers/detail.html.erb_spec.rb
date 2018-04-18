require 'rails_helper'
require 'fixtures/fake_models'

RSpec.describe "dataset/detail", type: :view do
  before(:each) do
    @dataset = assign(:dataset, fake_dataset('test_dataset'))
  end

  it "renders name in <h2>" do
    render
    expect(rendered).to match(%r{<h2>Dataset - test_dataset<\/h2>})
  end
end
