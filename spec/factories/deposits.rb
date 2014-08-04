# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deposit do
  end

  factory :deposits_receipt do
    receipt
    amount 100.0
  end
end
