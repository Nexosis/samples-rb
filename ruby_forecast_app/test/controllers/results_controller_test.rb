require 'test_helper'

class ResultsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/results"
    assert_response :success
  end

end
