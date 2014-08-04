# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :zero_amount_bill, :class => Bill do
    builder
    billed_date { generate(:date) }
    estimate
    payer :factory => :client
    factory :bill do
      after(:build) do |object, evaluator|
        object.bills_categories_templates << FactoryGirl.build(:bills_categories_template)
      end
      factory :paid_bill, traits: [:has_payments_bills]
      factory :invoiced_bill do
        after(:create) do |object, evaluator|
          object.bills_categories_templates.first.invoices_bills_categories_templates << FactoryGirl.build(:invoices_bills_categories_template)
        end
      end
    end
  end

  factory :bills_categories_template do
    categories_template :factory => :belong_to_estimate_categories_template
    after(:build) do |object, evaluator|
      object.bills_items << FactoryGirl.build(:bills_item)
    end
    factory :has_bill_bills_categories_template do
      bill
    end
  end

  factory :bills_item do
    item
    actual_cost 100.0
  end
end
