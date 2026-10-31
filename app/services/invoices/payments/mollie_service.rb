# frozen_string_literal: true

module Invoices
  module Payments
    class MollieService < BaseService
      include Customers::PaymentProviderFinder
      include TypedResults

      RESULTS = {update_payment_status: BaseResult[:payment, :invoice], generate_payment_url: BaseResult[:payment_url]}.freeze
      PROVIDER_NAME = "Mollie"

      private

      def generate_payment_url(invoice, payment_intent)
        @invoice = invoice
        mollie_payment = with_client do
          ::Mollie::Payment.create(
            amount: {value: format("%.2f", invoice.total_due_amount_cents / 100.0), currency: invoice.currency.upcase},
            description: invoice.number,
            redirect_url: success_redirect_url,
            webhook_url: webhook_url,
            expires_at: payment_intent.expires_at.iso8601,
            metadata: {lago_invoice_id: invoice.id, payment_type: "one-time"}
          )
        end
        result.payment_url = mollie_payment.checkout_url
        result
      rescue ::Mollie::Exception => e
        result.third_party_failure!(third_party: PROVIDER_NAME, error_code: e.class.name, error_message: e.message)
      end

      def update_payment_status(organization_id:, provider_payment_id:, status:)
        payment = Payment.find_by(provider_payment_id: provider_payment_id)
        return result.not_found_failure!(resource: "mollie_payment") unless payment

        result.payment = payment
        result.invoice = payment.payable
        return result if payment.payable.payment_succeeded?

        payment.update!(status:, payable_payment_status: payment.payment_provider.determine_payment_status(status))
        update_invoice_payment_status(payment.payment_provider.determine_payment_status(status))
        result
      rescue ActiveRecord::RecordInvalid => e
        result.record_validation_failure!(record: e.record)
      end

      attr_reader :invoice

      delegate :customer, to: :invoice

      def mollie_payment_provider
        @mollie_payment_provider ||= payment_provider(customer)
      end

      def with_client(&)
        ::Mollie::Client.with_api_key(mollie_payment_provider.api_key, &)
      end

      def success_redirect_url
        mollie_payment_provider.success_redirect_url.presence || PaymentProviders::MollieProvider::SUCCESS_REDIRECT_URL
      end

      def webhook_url
        Rails.application.routes.url_helpers.mollie_webhooks_url(mollie_payment_provider.organization_id, code: mollie_payment_provider.code)
      end

      def update_invoice_payment_status(status)
        Invoices::UpdateService.call!(invoice: result.invoice, params: {payment_status: status, ready_for_payment_processing: status.to_sym != :succeeded})
      end
    end
  end
end
