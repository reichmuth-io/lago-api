# frozen_string_literal: true

module PaymentProviders
  module Mollie
    class HandleEventJob < ApplicationJob
      def perform(organization_id:, payment_provider_id:, payment_id:)
        provider = PaymentProviders::MollieProvider.find(payment_provider_id)
        mollie_payment = ::Mollie::Client.with_api_key(provider.api_key) { ::Mollie::Payment.get(payment_id) }
        payment = Payment.find_by(provider_payment_id: mollie_payment.id)
        return unless payment

        status = mollie_payment.status
        payment.update!(status:, payable_payment_status: provider.determine_payment_status(status))
        return unless payment.payable_payment_status.to_sym == :succeeded

        if payment.payable.is_a?(Invoice)
          Invoices::UpdateService.call!(
            invoice: payment.payable,
            params: {payment_status: :succeeded, ready_for_payment_processing: false}
          )
        elsif payment.payable.is_a?(PaymentRequest)
          PaymentRequests::UpdateService.call!(
            payable: payment.payable,
            params: {payment_status: :succeeded, ready_for_payment_processing: false}
          )
        end
      end
    end
  end
end
