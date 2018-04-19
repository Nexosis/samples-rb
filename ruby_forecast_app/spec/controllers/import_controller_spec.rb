require 'rails_helper'

RSpec.describe ImportController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns imports and datasets lists' do
      get :index
      expect(assigns(:imports)).not_to be_nil
      expect(assigns(:datasets)).not_to be_nil
    end
  end
end
