# frozen_string_literal: true

module Mutations
  module PaymentProviders
    module Mollie
      class Create < Base
        REQUIRED_PERMISSION = "organization:integrations:create"
        graphql_name "AddMolliePaymentProvider"
        description "Add or update Mollie payment provider"
        input_object_class Types::PaymentProviders::MollieInput
        type Types::PaymentProviders::Mollie
      end
    end
  end
end
