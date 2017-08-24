require 'test_helper'
require_relative '../classes/fake_client'

class AccountControllerTest < ActionDispatch::IntegrationTest
  setup do
      ApplicationController.initialize_factory(Proc.new {|instance| FakeClient.new})
  end

  test "should get index" do
    get '/account/'
    assert_response :success
  end

  test "should get sessions" do
    get '/sessions/'
    assert_response :success
  end

end
