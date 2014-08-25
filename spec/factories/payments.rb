# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    builder
    account
    payer :factory => :client
    date { generate(:date) }
    method { generate(:payment_method) }
    after(:build) do |object, evaluator|
      object.payments_bills << FactoryGirl.build(:payments_bill)
    end
  end

  factory :payments_bill do
    bill
    amount 100.0
  end

  factory :has_payment_payments_bill, :class => PaymentsBill do
    payment
    amount 100.0
  end
end
