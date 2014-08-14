# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :company do
    company_name { generate(:name) }
    factory :builder, :class => Base::Builder
  end

end