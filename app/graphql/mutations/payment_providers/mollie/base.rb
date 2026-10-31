# frozen_string_literal: true

module Mutations
  module PaymentProviders
    module Mollie
      class Base < BaseMutation
        include AuthenticableApiUser
        include RequiredOrganization

        def resolve(**args)
          result = ::PaymentProviders::MollieService.new(context[:current_user])
            .create_or_update(**args.merge(organization: current_organization))

          result.success? ? result.mollie_provider : result_error(result)
        end
      end
    end
  end
end
