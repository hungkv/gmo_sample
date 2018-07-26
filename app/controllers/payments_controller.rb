class PaymentsController < ApplicationController
  before_action :load_params
  skip_before_action :verify_authenticity_token
  def unionpay_start
    @order_id = DateTime.now.strftime("%Q")
    @gmo_auth = @gmo.entry_tran_unionpay(order_id: @order_id, job_cd: "AUTH", amount: 1000, td_flag: false)
    @unionpay_connect = @gmo.exec_tran_unionpay(access_id: @gmo_auth["AccessID"], access_pass: @gmo_auth["AccessPass"], order_id: @order_id, ret_url: "http://localhost:3000/payments/create_payment", error_rcv_url: "http://localhost:3000")
    @unionpay_token = @unionpay_connect["Token"].gsub!(/\s/,'+')
    @start_url = @unionpay_connect["StartURL"]
    @access_id = @unionpay_connect["AccessID"]
    session[:gmo_auth] ||= @gmo_auth
  end

  def confirm
  end

  def create_payment
    @gmo.sale_tran_unionpay(access_id: session[:gmo_auth]["AccessID"], access_pass: session[:gmo_auth]["AccessPass"], order_id: params["OrderID"], amount: 1000)
    cookies[:gmo_auth] = nil
    flash[:message] = "Payment Success"
    redirect_to "/"
  end

  private
  def load_params
    @gmo = GMO::Payment::ShopAPI.new({shop_id: "tshop00034657", shop_pass: "t8fcee3v", host: "kt01.mul-pay.jp"})
  end
end

