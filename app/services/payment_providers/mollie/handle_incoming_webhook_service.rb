# frozen_string_literal: true

module PaymentProviders
  module Mollie
    class HandleIncomingWebhookService < BaseService
      Result = BaseResult

      def initialize(organization_id:, payment_id:, code: nil)
        @organization_id = organization_id
        @payment_id = payment_id
        @code = code
        super
      end

      def call
        provider_result = PaymentProviders::FindService.call(
          organization_id:, code:, payment_provider_type: "mollie"
        )
        return provider_result unless provider_result.success?

        PaymentProviders::Mollie::HandleEventJob.perform_later(
          organization_id:, payment_provider_id: provider_result.payment_provider.id, payment_id:
        )
        result
      end

      private

      attr_reader :organization_id, :payment_id, :code
    end
  end
end
