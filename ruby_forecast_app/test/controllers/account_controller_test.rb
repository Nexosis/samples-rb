require 'test_helper'

class AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get 'account/'
    assert_response :success
  end

end
