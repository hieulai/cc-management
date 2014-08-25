# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transfer do
    from_account factory: :account
    to_account factory: :account
    date { generate(:date) }
    amount 100.0
  end
end
