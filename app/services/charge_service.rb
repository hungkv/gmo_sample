class ChargeService < BaseService
  def initialize(amount)
    @amount = amount
  end

  def perform
    entry_transaction
  end

  private

  def entry_transaction
    byebug
    @order_id = DateTime.now.strftime("%Q")
    entry_tran = entry_payment
    return entry_tran if entry_tran.key?("ErrCode")
    @access_id = entry_tran["AccessID"]
    @access_pass = entry_tran["AccessPass"]

    entry_exec = auth_payment
    return entry_exec if entry_exec.key?(Settings.gmo.error_code)
    puts entry_exec["Token"]
    puts entry_exec["StartURL"]
    entry_exec
  end

  def entry_payment
    TransactionEntryUnionpayService.new.perform({
      order_id: @order_id,
      job_cd: "AUTH",
      amount: @amount
    })
  end

  def auth_payment
    TransactionExecuteUnionpayService.new.perform({
      order_id: @order_id,
      access_id: @access_id,
      access_pass: @access_pass,
      ret_url: unionpay_success_url(user_id: 1),
      error_rcv_url: unionpay_fail_url(user_id: 1)
    })
  end
end
