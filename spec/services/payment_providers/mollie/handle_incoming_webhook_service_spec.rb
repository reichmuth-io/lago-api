# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentProviders::Mollie::HandleIncomingWebhookService do
  subject(:webhook_service) { described_class.new(organization_id:, payment_id:, code:) }

  let(:organization) { create(:organization) }
  let(:organization_id) { organization.id }
  let(:provider) { create(:mollie_provider, organization:, code: "mollie_1") }
  let(:payment_id) { "tr_test" }
  let(:code) { provider.code }

  before { provider }

  it "enqueues Mollie payment processing" do
    result = webhook_service.call

    expect(result).to be_success
    expect(PaymentProviders::Mollie::HandleEventJob).to have_been_enqueued.with(
      organization_id:, payment_provider_id: provider.id, payment_id:
    )
  end

  context "when the provider cannot be found" do
    let(:code) { "unknown" }

    it "returns the provider lookup failure" do
      expect(webhook_service.call).not_to be_success
    end
  end
end
