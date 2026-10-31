# frozen_string_literal: true

module PaymentProviders
  module Mollie
    module Customers
      class CreateService < BaseService
        Result = BaseResult[:provider_customer]

        def initialize(customer:, payment_provider_id:, params:, async: true)
          @customer = customer
          @payment_provider_id = payment_provider_id
          @params = params || {}
          super
        end

        def call
          provider_customer = PaymentProviderCustomers::MollieCustomer.find_or_initialize_by(customer_id: customer.id)
          provider_customer.payment_provider_id = payment_provider_id
          provider_customer.organization_id = customer.organization_id
          provider_customer.sync_with_provider = params[:sync_with_provider] if params.key?(:sync_with_provider)
          provider_customer.save!
          result.provider_customer = provider_customer
          result
        rescue ActiveRecord::RecordInvalid => e
          result.record_validation_failure!(record: e.record)
        end

        private

        attr_reader :customer, :payment_provider_id, :params
      end
    end
  end
end
