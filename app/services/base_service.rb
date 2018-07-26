class BaseService
  def initialize(client = nil, error_info = nil, results = nil)
    @client = client
    @error_info = error_info
    @results = results
  end

  def perform(options)
    @results = execute_request(options)
  rescue GMO::Payment::APIError => err
    gmo_error_log(err.as_json, options)
    Rails.logger.error("GMOPaymentAPI: #{err}")
    @error_info = err.error_info
  end

  def execute_request(options)
    raise NotImplementedError
  end

  def results_format
    (@results || {}).inject([]) do |array, key_value|
      key_value.last.to_s.split("|", -1).each_with_index do |split_value, index|
        hash = array[index] || {}
        hash[key_value.first] = split_value
        array[index] = hash
      end
      array
    end
  end

  private
  def gmo_error_log(reason, options)
    case self.class.to_s
    when "Payment::TransactionChangeService"
      if options[:job_cd] == Settings.gmo.authenticate
        end_point = "gmo.temporary_sales.cancel"
      else
        end_point = "gmo.refund_part"
      end
    when "Payment::TransactionAlterService"
      end_point = "gmo.refund_all"
    when "Payment::TransactionAlterSalesService"
      end_point = "gmo.actual_sales"
    end
    return unless end_point
    ApiErrorLog.create(user_id: options[:member_id], booking_id: options[:booking_id],
      end_point: end_point, reason: reason)
  end
end

