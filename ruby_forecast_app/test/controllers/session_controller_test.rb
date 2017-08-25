require 'test_helper'
require_relative '../classes/fake_client'

class SessionControllerTest < ActionDispatch::IntegrationTest
  setup do
      SessionController.initialize_factory(Proc.new {|instance| FakeClient.new})
  end

  test "should get sessions" do
    get '/sessions/'
    assert_response :success
  end

end