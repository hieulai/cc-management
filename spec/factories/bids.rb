# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bid do
    builder
    project
    category
    factory :chosen_bid do
      chosen true
    end
  end
end
