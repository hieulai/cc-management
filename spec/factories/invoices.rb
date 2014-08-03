# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invoice do
    builder
    estimate
    factory :guaranteed_bid_invoice do
      estimate :factory => :guaranteed_bid_estimate
    end

    factory :cost_plus_bid_invoice do
      estimate :factory => :cost_plus_bid_estimate
    end

    factory :paid_invoice do
      after(:build) do |object, evaluator|
        object.receipts_invoices << FactoryGirl.build(:receipts_invoice)
      end
    end
  end

  factory :invoices_item do
    item
    amount 100.0
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
