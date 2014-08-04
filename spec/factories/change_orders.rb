# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :change_order do
    name { generate(:name) }
    factory :has_billed_items_change_order do
      after(:build) do |object, evaluator|
        object.change_orders_categories << FactoryGirl.build(:has_billed_items_change_orders_category)
      end
    end
    factory :has_invoiced_items_change_order do
      after(:build) do |object, evaluator|
        object.change_orders_categories << FactoryGirl.build(:has_invoiced_items_change_orders_category)
      end
    end
  end

  factory :change_orders_category do
    category
    change_order
    after(:build) do |object, evaluator|
      object.items << FactoryGirl.build(:item)
    end

    factory :has_billed_items_change_orders_category do
      after(:build) do |object, evaluator|
        bill = FactoryGirl.create(:bill)
        bills_item = FactoryGirl.build(:bills_item)
        bill.bills_categories_templates.first.bills_items << bills_item
        object.items.first.bills_items << bills_item
      end
    end

    factory :has_invoiced_items_change_orders_category do
      after(:build) do |object, evaluator|
        invoice = FactoryGirl.create(:guaranteed_bid_invoice)
        invoices_item = FactoryGirl.build(:has_item_invoices_item)
        invoice.invoices_items << invoices_item
        object.items.first.invoices_items << invoices_item
      end
    end
  end
end
