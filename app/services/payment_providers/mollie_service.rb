# frozen_string_literal: true

module PaymentProviders
  class MollieService < BaseService
    Result = BaseResult[:mollie_provider]

    def create_or_update(**args)
      provider_result = PaymentProviders::FindService.call(
        organization_id: args[:organization].id, code: args[:code], id: args[:id], payment_provider_type: "mollie"
      )
      provider = if provider_result.success?
        provider_result.payment_provider
      else
        PaymentProviders::MollieProvider.new(organization_id: args[:organization].id, code: args[:code])
      end

      old_code = provider.code
      provider.api_key = args[:api_key] if args.key?(:api_key)
      provider.success_redirect_url = args[:success_redirect_url] if args.key?(:success_redirect_url)
      provider.code = args[:code] if args.key?(:code)
      provider.name = args[:name] if args.key?(:name)
      provider.save!
      provider.customers.update_all(payment_provider_code: args[:code]) if payment_provider_code_changed?(provider, old_code, args) # rubocop:disable Rails/SkipsModelValidations

      result.mollie_provider = provider
      result
    rescue ActiveRecord::RecordInvalid => e
      result.record_validation_failure!(record: e.record)
    end
  end
end
