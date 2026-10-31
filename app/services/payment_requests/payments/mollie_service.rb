# frozen_string_literal: true

module PaymentRequests
  module Payments
    class MollieService < Invoices::Payments::MollieService
      private

      def generate_payment_url(payable, payment_intent)
        @payable = payable
        mollie_payment = with_request_client do
          ::Mollie::Payment.create(
            amount: {value: format("%.2f", payable.total_amount_cents / 100.0), currency: payable.currency.upcase},
            description: payable.id,
            redirect_url: request_success_redirect_url,
            webhook_url: request_webhook_url,
            expires_at: payment_intent.expires_at.iso8601,
            metadata: {lago_payable_id: payable.id, lago_payable_type: payable.class.name, payment_type: "one-time"}
          )
        end
        result.payment_url = mollie_payment.checkout_url
        result
      rescue ::Mollie::Exception => e
        result.third_party_failure!(third_party: "Mollie", error_code: e.class.name, error_message: e.message)
      end

      attr_reader :payable

      def with_request_client(&)
        ::Mollie::Client.with_api_key(payment_provider(payable.customer).api_key, &)
      end

      def request_success_redirect_url
        provider = payment_provider(payable.customer)
        provider.success_redirect_url.presence || PaymentProviders::MollieProvider::SUCCESS_REDIRECT_URL
      end

      def request_webhook_url
        provider = payment_provider(payable.customer)
        Rails.application.routes.url_helpers.mollie_webhooks_url(provider.organization_id, code: provider.code)
      end
    end
  end
end
