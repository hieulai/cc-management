# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :receipt do
    builder
    method { generate(:receipt_method) }
    received_at { generate(:date) }
    client
  end
end
