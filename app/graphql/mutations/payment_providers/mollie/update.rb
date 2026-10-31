# frozen_string_literal: true

module Mutations
  module PaymentProviders
    module Mollie
      class Update < Base
        REQUIRED_PERMISSION = "organization:integrations:update"
        graphql_name "UpdateMolliePaymentProvider"
        description "Update Mollie payment provider"
        input_object_class Types::PaymentProviders::UpdateInput
        type Types::PaymentProviders::Mollie
      end
    end
  end
end
