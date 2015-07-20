require 'test_helper'

class SuspiciousKeywordsControllerTest < ActionController::TestCase
  setup do
    @suspicious_keyword = suspicious_keywords(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:suspicious_keywords)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create suspicious_keyword" do
    assert_difference('SuspiciousKeyword.count') do
      post :create, suspicious_keyword: { keyword: @suspicious_keyword.keyword }
    end

    assert_redirected_to suspicious_keyword_path(assigns(:suspicious_keyword))
  end

  test "should show suspicious_keyword" do
    get :show, id: @suspicious_keyword
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @suspicious_keyword
    assert_response :success
  end

  test "should update suspicious_keyword" do
    patch :update, id: @suspicious_keyword, suspicious_keyword: { keyword: @suspicious_keyword.keyword }
    assert_redirected_to suspicious_keyword_path(assigns(:suspicious_keyword))
  end

  test "should destroy suspicious_keyword" do
    assert_difference('SuspiciousKeyword.count', -1) do
      delete :destroy, id: @suspicious_keyword
    end

    assert_redirected_to suspicious_keywords_path
  end
end
