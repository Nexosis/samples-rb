require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns session and dataset lists' do
      get :index
      expect(assigns(:datasets)).not_to be_nil
      expect(assigns(:sessions)).not_to be_nil
    end
  end
end
