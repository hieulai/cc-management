# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :template do
    name { generate(:name) }
    builder
    factory :belong_to_estimate_template do
      estimate
    end

    factory :has_categories_templates_template do
      after(:build) do |object, evaluator|
        object.categories_templates << FactoryGirl.build(:categories_template)
      end
    end
  end
end
