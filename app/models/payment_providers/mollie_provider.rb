# frozen_string_literal: true

module PaymentProviders
  class MollieProvider < BaseProvider
    SUCCESS_REDIRECT_URL = "https://www.mollie.com/"

    PROCESSING_STATUSES = %w[open pending authorized].freeze
    SUCCESS_STATUSES = %w[paid].freeze
    FAILED_STATUSES = %w[canceled expired failed].freeze

    validates :api_key, presence: true
    validates :success_redirect_url, url: true, allow_nil: true, length: {maximum: 1024}

    secrets_accessors :api_key

    def payment_type
      "mollie"
    end
  end
end
