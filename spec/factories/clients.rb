# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :client do
    builder
    factory :has_payments_client,  traits: [:has_payments]
    factory :has_receipts_client,  traits: [:has_receipts]
    factory :has_bills_client,  traits: [:has_bills]
    factory :has_purchase_orders_client,  traits: [:has_purchase_orders]
    factory :has_projects_client,  traits: [:has_projects]
  end
end
