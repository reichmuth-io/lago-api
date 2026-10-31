# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentProviderCustomers::MollieService do
  subject(:generate_checkout_url) { described_class.call(:generate_checkout_url, mollie_customer) }

  let(:mollie_customer) { build_stubbed(:mollie_customer) }

  it "returns a feature-not-supported failure" do
    expect(generate_checkout_url).not_to be_success
    expect(generate_checkout_url.error).to be_a(BaseService::MethodNotAllowedFailure)
    expect(generate_checkout_url.error.code).to eq("feature_not_supported")
  end
end
