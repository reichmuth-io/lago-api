# frozen_string_literal: true

module PaymentProviderCustomers
  class MollieService < BaseService
    include TypedResults

    RESULTS = {
      create: BaseResult[:mollie_customer],
      update: BaseResult,
      generate_checkout_url: BaseResult
    }.freeze

    private

    def create(mollie_customer)
      result.mollie_customer = mollie_customer
      result
    end

    def update(_mollie_customer)
      result
    end

    def generate_checkout_url(_mollie_customer, send_webhook: true)
      result.not_allowed_failure!(code: "feature_not_supported")
    end
  end
end
