require 'rails_helper'

RSpec.describe DatasetController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # DatasetController. As you add validations to DatasetController, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { dataset_name: 'test_dataset',
      page_size: 10,
      page_number: 0
    }
  }

  let(:invalid_attributes) {
    skip('Add a hash of attributes invalid for your model')
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DatasetController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: valid_attributes, session: valid_session
      expect(response).to be_success
    end
  end

  describe 'GET #detail' do
    it 'returns a success response' do
      get :detail, params: valid_attributes, session: valid_session
      expect(response).to be_success
    end
  end

  describe 'POST #update' do
    it 'returns a success response' do
      addl_attrs = { column: { 0 => 'test_col' },
                     role: { 0 => 'none' },
                     datatype: { 0 => 'numeric' },
                     imputation: { 0 => 'zeroes' },
                     aggregation: { 0 => 'sum' } }
      post :update, params: valid_attributes.merge(addl_attrs), session: valid_session
      expect(response).to redirect_to action: :detail, dataset_name: 'test_dataset'
    end
  end
end
