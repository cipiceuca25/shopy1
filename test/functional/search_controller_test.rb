require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "should get do_the_search" do
    get :do_the_search
    assert_response :success
  end

end
