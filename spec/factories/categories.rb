# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do
    builder
    name { generate(:name) }

    factory :has_paid_categories_templates_category do
      after(:build) do |object, evaluator|
        object.categories_templates << FactoryGirl.build(:has_paid_bills_categories_template)
      end
    end

    factory :has_paid_change_orders_category do
      after(:build) do |object, evaluator|
        object.change_orders_categories << FactoryGirl.build(:has_billed_items_change_orders_category)
      end
    end

    factory :has_chosen_bids_category do
      after(:build) do |object, evaluator|
        object.bids << FactoryGirl.build(:chosen_bid)
      end
    end
  end

  factory :categories_template do
    template
    category
    factory :belong_to_estimate_categories_template do
      template :factory => :belong_to_estimate_template

      after(:build) do |object, evaluator|
        object.items << FactoryGirl.build(:item)
      end

      factory :has_paid_bills_categories_template do
        after(:build) do |object, evaluator|
          bill = FactoryGirl.create(:paid_bill)
          bct = FactoryGirl.build(:bills_categories_template)
          bct.bills_items << FactoryGirl.build(:bills_item)
          bill.bills_categories_templates << bct
          object.bills_categories_templates << bct
        end
      end
      factory :has_invoiced_bills_categories_template  do
        after(:build) do |object, evaluator|
          bill = FactoryGirl.create(:invoiced_bill)
          bct = FactoryGirl.build(:bills_categories_template)
          bct.bills_items << FactoryGirl.build(:bills_item)
          bill.bills_categories_templates << bct
          object.bills_categories_templates << bct
        end
      end
    end
  end
end
