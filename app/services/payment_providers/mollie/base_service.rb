# frozen_string_literal: true

module PaymentProviders
  module Mollie
    class BaseService < ::BaseService
      private

      def with_client(provider)
        ::Mollie::Client.with_api_key(provider.api_key) { yield }
      end
    end
  end
end
