# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :template do
    name { generate(:name) }
    factory :belong_to_estimate_template do
      estimate
    end
  end
end
