class ChargesController < ApplicationController
  def create
    redirect_to payments_unionpay_start_path()
  end
end
