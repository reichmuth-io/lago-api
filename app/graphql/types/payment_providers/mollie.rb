# frozen_string_literal: true

module Types
  module PaymentProviders
    class Mollie < Types::BaseObject
      graphql_name "MollieProvider"

      field :code, String, null: false
      field :id, ID, null: false
      field :name, String, null: false
      field :api_key, ObfuscatedStringType, null: true, permission: "organization:integrations:view"
      field :success_redirect_url, String, null: true, permission: "organization:integrations:view"
    end
  end
end
