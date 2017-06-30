require 'test_helper'
require_relative '../classes/fake_client'

class ResultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ApplicationController.initialize_factory(Proc.new {|instance| FakeClient.new})
  end

  test "should get index" do
    get "/results/015ce5ae-8d87-401e-9ee5-9b0098fc7897"
    assert_response :success
  end

end
