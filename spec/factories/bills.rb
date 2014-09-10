# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :zero_amount_bill, :class => Bill do
    builder
    billed_date { generate(:date) }
    estimate :factory => :committed_estimate
    payer :factory => :client
    factory :bill do
      after(:build) do |object, evaluator|
        object.bills_categories_templates << FactoryGirl.build(:bills_categories_template)
      end
      factory :paid_bill do
        after(:create) do |object, evaluator|
          object.payments_bills << FactoryGirl.build(:has_payment_payments_bill)
        end
      end
      factory :invoiced_bill do
        after(:create) do |object, evaluator|
          object.bills_categories_templates.first.invoices_bills_categories_templates << FactoryGirl.build(:invoices_bills_categories_template)
        end
      end
    end
    factory :unjob_costed_bill do
      job_costed false
      after(:build) do |object, evaluator|
        object.un_job_costed_items << FactoryGirl.build(:un_job_costed_item)
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

  factory :un_job_costed_item do
    account
    amount 100.0
    name { generate(:name) }
  end

  factory :bills_item do
    item
    actual_cost 100.0
  end
end
