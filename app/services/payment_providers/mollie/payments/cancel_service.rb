# frozen_string_literal: true

module PaymentProviders
  module Mollie
    module Payments
      class CancelService < PaymentProviders::Mollie::BaseService
        Result = BaseResult

        def initialize(payment:)
          @payment = payment
          super
        end

        def call
          with_client(payment.payment_provider) { ::Mollie::Payment.get(payment.provider_payment_id).cancel }
          result
        end

        private

        attr_reader :payment
      end
    end
  end
end
