# frozen_string_literal: true

module Types
  module PaymentProviders
    class MollieInput < BaseInputObject
      description "Mollie input arguments"

      argument :api_key, String, required: true
      argument :code, String, required: true
      argument :name, String, required: true
      argument :success_redirect_url, String, required: false
    end
  end
end
