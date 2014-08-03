# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vendor do
    builder
    vendor_type { generate(:vendor_type) }
    trade { generate(:name) }
    factory :has_payments_vendor,  traits: [:has_payments]
    factory :has_receipts_vendor,  traits: [:has_receipts]
    factory :has_bills_vendor,  traits: [:has_bills]
    factory :has_purchase_orders_vendor,  traits: [:has_purchase_orders]
    factory :has_bids_vendor,  traits: [:has_bids]
  end
end
