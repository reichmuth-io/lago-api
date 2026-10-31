# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentProviders::Mollie::Payments::CreateService do
  subject(:create_service) { described_class.new(payment:, reference: "Invoice 123", metadata: {}) }

  let(:customer) { create(:customer) }
  let(:organization) { customer.organization }
  let(:payment_provider) { create(:mollie_provider, organization:) }
  let(:mollie_customer) { create(:mollie_customer, customer:, payment_provider:) }
  let(:invoice) { create(:invoice, organization:, customer:, total_amount_cents: 1_000, currency: "EUR") }
  let(:payment) do
    create(
      :payment,
      payable: invoice,
      payment_provider:,
      payment_provider_customer: mollie_customer,
      amount_cents: 1_000,
      amount_currency: "EUR",
      status: "pending",
      payable_payment_status: "pending"
    )
  end
  let(:mollie_payment) { instance_double(Mollie::Payment, id: "tr_test", status: "open") }

  before do
    allow(Mollie::Client).to receive(:with_api_key).and_yield
    allow(Mollie::Payment).to receive(:create).and_return(mollie_payment)
  end

  it "registers the payment with Mollie and keeps it processing" do
    result = create_service.call

    expect(result).to be_success
    expect(result.payment.provider_payment_id).to eq("tr_test")
    expect(result.payment.status).to eq("open")
    expect(result.payment.payable_payment_status).to eq("processing")
    expect(Mollie::Payment).to have_received(:create).with(hash_including(
      amount: {value: "10.00", currency: "EUR"},
      description: "Invoice 123"
    ))
  end
end
