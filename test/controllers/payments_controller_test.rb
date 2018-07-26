require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get unionpay_start" do
    get payments_unionpay_start_url
    assert_response :success
  end

end
