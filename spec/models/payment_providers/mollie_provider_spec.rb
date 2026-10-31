# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentProviders::MollieProvider do
  subject(:provider) { build(:mollie_provider) }

  it { is_expected.to validate_presence_of(:api_key) }
  it { is_expected.to validate_length_of(:success_redirect_url).is_at_most(1024).allow_nil }

  describe "#payment_type" do
    it "returns mollie" do
      expect(provider.payment_type).to eq("mollie")
    end
  end

  describe "#determine_payment_status" do
    it "maps Mollie statuses" do
      expect(provider.determine_payment_status("open")).to eq(:processing)
      expect(provider.determine_payment_status("authorized")).to eq(:processing)
      expect(provider.determine_payment_status("paid")).to eq(:succeeded)
      expect(provider.determine_payment_status("failed")).to eq(:failed)
    end
  end
end
