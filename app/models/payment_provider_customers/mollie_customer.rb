# frozen_string_literal: true

module PaymentProviderCustomers
  class MollieCustomer < BaseCustomer
    def require_provider_payment_id?
      false
    end
  end
end
