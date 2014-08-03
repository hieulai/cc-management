# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    builder
    factory :has_payments_contact,  traits: [:has_payments]
    factory :has_receipts_contact,  traits: [:has_receipts]
    factory :has_bills_contact,  traits: [:has_bills]
    factory :has_purchase_orders_contact,  traits: [:has_purchase_orders]
  end
end
