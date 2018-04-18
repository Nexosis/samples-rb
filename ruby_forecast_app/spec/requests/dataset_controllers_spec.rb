require 'rails_helper'

RSpec.describe "DatasetController", type: :request do
  describe "GET /dataset" do
    it "works! (now write some real specs)" do
      get '/dataset'
      expect(response).to have_http_status(200)
    end
  end
end
