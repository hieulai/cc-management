# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invoice do
    builder
    estimate

    after(:build) do |object, evaluator|
      object.invoices_items << FactoryGirl.build(:has_item_invoices_item)
    end
    factory :guaranteed_bid_invoice do
      estimate :factory => :guaranteed_bid_estimate
    end

    factory :cost_plus_bid_invoice do
      estimate :factory => :cost_plus_bid_estimate
    end

    factory :paid_invoice do
      estimate  :factory => :committed_estimate
      after(:create) do |object, evaluator|
        FactoryGirl.create(:client_receipt_receipt, client: object.project.client)
        object.reload
      end
    end
  end

  factory :invoices_item do
    amount 100.0
    factory :has_invoice_invoices_item do
      invoice
    end

    factory :has_item_invoices_item do
      item :factory => :has_categories_templates_item
    end
  end

  factory :receipts_invoice do
    receipt
    amount 100.0
  end

  factory :invoices_bills_categories_template do
    invoice
    amount 100.0
  end
end
