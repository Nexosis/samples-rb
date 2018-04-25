require 'rails_helper'

RSpec.describe ResultsController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns session and dataset lists' do
      get :index, {params: {session_id: '0162b017-328b-48b7-abcb-70406b3f480e'}}
      expect(assigns(:datasets)).not_to be_nil
      expect(assigns(:session)).not_to be_nil
      expect(assigns(:session_result)).not_to be_nil
    end
  end

  describe 'GET #features' do
    it 'assigns feature object' do
      get :features, {params: {session_id: '0162cfce-1ecc-4733-aaa4-02db0ce799d2'}}
      expect(assigns(:feature_results)).not_to be_nil
    end
  end
end
