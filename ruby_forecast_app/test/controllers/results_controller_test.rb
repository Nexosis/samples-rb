require 'test_helper'

class ResultsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/results/015ce5ae-8d87-401e-9ee5-9b0098fc7897"
    assert_response :success
  end

end
