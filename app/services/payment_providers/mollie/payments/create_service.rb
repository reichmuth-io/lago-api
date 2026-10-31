# frozen_string_literal: true

module PaymentProviders
  module Mollie
    module Payments
      class CreateService < PaymentProviders::Mollie::BaseService
        Result = BaseResult[:payment, :error_message, :error_code, :reraise, :should_retry]

        def initialize(payment:, reference:, metadata:)
          @payment = payment
          @reference = reference
          @metadata = metadata
          super
        end

        def call
          mollie_payment = with_client(payment_provider) do
            ::Mollie::Payment.create(payment_params)
          end

          payment.provider_payment_id = mollie_payment.id
          payment.status = mollie_payment.status
          payment.payable_payment_status = payment_provider.determine_payment_status(mollie_payment.status)
          payment.save!
          result.payment = payment
          result
        rescue ::Mollie::Exception => e
          payment.update!(status: :failed, payable_payment_status: :failed)
          result.service_failure!(code: "mollie_error", message: e.message)
        rescue Faraday::ConnectionFailed => e
          raise Invoices::Payments::ConnectionError, e
        end

        private

        attr_reader :payment, :reference, :metadata

        delegate :payment_provider, :customer, to: :payment

        def payment_params
          {
            amount: {value: format("%.2f", payment.amount_cents / 100.0), currency: payment.amount_currency.upcase},
            description: reference.to_s,
            redirect_url: payment_provider.success_redirect_url.presence || PaymentProviders::MollieProvider::SUCCESS_REDIRECT_URL,
            webhook_url: webhook_url,
            metadata: metadata.stringify_keys.merge("payment_id" => payment.id)
          }
        end

        def webhook_url
          Rails.application.routes.url_helpers.mollie_webhooks_url(payment_provider.organization_id, code: payment_provider.code)
        end
      end
    end
  end
end
