# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :zero_amount_purchase_order, :class => PurchaseOrder do
    builder
    date { generate(:date) }
    estimate
    payer :factory => :client

    factory :purchase_order do
      after(:build) do |object, evaluator|
        object.purchase_orders_categories_templates << FactoryGirl.build(:purchase_orders_categories_template)
      end

      factory :paid_purchase_order do
        after(:create) do |object, evaluator|
          object.bill.payments_bills << FactoryGirl.build(:payments_bill)
        end
      end
    end
  end

  factory :purchase_orders_categories_template do
    categories_template :factory => :belong_to_estimate_categories_template
    after(:build) do |object, evaluator|
      object.purchase_orders_items << FactoryGirl.build(:purchase_orders_item)
    end
  end

  factory :purchase_orders_item do
    item
    actual_cost 100.0
  end
end
