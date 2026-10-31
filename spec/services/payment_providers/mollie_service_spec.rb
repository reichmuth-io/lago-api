# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentProviders::MollieService do
  subject(:mollie_service) { described_class.new(membership.user) }

  let(:membership) { create(:membership) }
  let(:organization) { membership.organization }
  let(:code) { "mollie_1" }
  let(:name) { "Mollie" }
  let(:api_key) { "test_#{SecureRandom.hex(8)}" }
  let(:success_redirect_url) { Faker::Internet.url }

  describe "#create_or_update" do
    it "creates a Mollie provider" do
      expect do
        mollie_service.create_or_update(organization:, code:, name:, api_key:, success_redirect_url:)
      end.to change(PaymentProviders::MollieProvider, :count).by(1)
    end

    context "when a provider already exists" do
      let!(:provider) { create(:mollie_provider, organization:, code:) }

      it "updates the existing provider" do
        result = mollie_service.create_or_update(organization:, code:, name:, api_key:, success_redirect_url:)

        expect(result).to be_success
        expect(result.mollie_provider).to eq(provider)
        expect(result.mollie_provider.api_key).to eq(api_key)
        expect(result.mollie_provider.name).to eq(name)
        expect(result.mollie_provider.success_redirect_url).to eq(success_redirect_url)
      end
    end

    context "when required values are missing" do
      it "returns validation errors" do
        result = mollie_service.create_or_update(organization:)

        expect(result).not_to be_success
        expect(result.error.messages[:api_key]).to eq(["value_is_mandatory"])
        expect(result.error.messages[:name]).to eq(["value_is_mandatory"])
      end
    end
  end
end
