# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :builder, :class => Base::Builder do
    company_name { generate(:name) }
  end
end
