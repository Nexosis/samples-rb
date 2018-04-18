require 'rails_helper'
require_relative '../fixtures/fake_client'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /nexosisdev.com/).to_rack(FakeClient)
  end
end

RSpec.describe SessionController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
