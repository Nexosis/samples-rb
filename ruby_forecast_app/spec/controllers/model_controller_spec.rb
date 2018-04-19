require 'rails_helper'

RSpec.describe ModelController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns models list' do
      get :index
      expect(assigns(:models)).not_to be_nil
    end
  end
end
