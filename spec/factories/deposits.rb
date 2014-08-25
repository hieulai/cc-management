# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deposit do
    builder
    account
    date { generate(:date) }
    after(:build) do |object, evaluator|
      object.deposits_receipts << FactoryGirl.build(:deposits_receipt)
    end
  end

  factory :deposits_receipt do
    receipt
    amount 100.0
  end
end
