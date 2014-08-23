# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :company do
    company_name { generate(:name) }
    city { generate(:name) }
    state { generate(:name) }
    factory :builder, :class => Base::Builder do
      company_name "Construction Central"
      initialize_with { Base::Builder.where(:company_name => company_name).first_or_create }
    end
  end

end
