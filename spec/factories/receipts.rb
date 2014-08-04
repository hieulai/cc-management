# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :receipt do
    builder
    method { generate(:receipt_method) }
    received_at { generate(:date) }
    payer :factory => :client
    payor "smb"
    kind "uninvoiced"

    after(:build) do |object, evaluator|
      object.receipts_items << FactoryGirl.build(:receipts_item)
    end

    factory :paid_receipt, traits: [:has_deposits_receipts]
  end

  factory :receipts_item do
    account
    amount 100.0
  end
end
