# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    builder
    account
    payer :factory => :client
    date { generate(:date) }
    method { generate(:payment_method) }
  end

  factory :payments_bill do
    payment
    amount 100.0
  end
end
