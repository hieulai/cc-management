# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    builder
    name { generate(:name) }

    factory :has_categories_templates_item do
      after(:build) do |object, evaluator|
        object.categories_templates << FactoryGirl.build(:belong_to_estimate_categories_template)
      end
    end

    factory :has_bills_item do
      bills_categories_template :factory => :has_bill_bills_categories_template
    end

    factory :has_invoices_item do
      after(:build) do |object, evaluator|
        object.invoices_items << FactoryGirl.build(:has_invoice_invoices_item)
      end
    end

    factory :has_bids_item do
      after(:build) do |object, evaluator|
        object.bids_items << FactoryGirl.build(:bids_item)
      end
    end
  end
end
