# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :receipt do
    builder
    method { generate(:receipt_method) }
    received_at { generate(:date) }
    payer :factory => :client
    payor { generate(:name) }
    kind "uninvoiced"

    after(:build) do |object, evaluator|
      object.receipts_items << FactoryGirl.build(:receipts_item)
    end

    factory :client_receipt_receipt do
      client factory: :has_projects_client
      kind "client_receipt"
      applied_amount 300.0
      after(:build) do |object, evaluator|
        FactoryGirl.create :invoice, estimate: object.client.projects.first.committed_estimate
      end
    end

    factory :paid_receipt, traits: [:has_deposits_receipts]
  end

  factory :receipts_item do
    account
    amount 100.0
  end

  factory :has_invoice_receipts_invoice, :class => ReceiptsInvoice do
    invoice
    amount 100.0
  end
end
