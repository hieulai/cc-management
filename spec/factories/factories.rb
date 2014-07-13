FactoryGirl.define do
  sequence :name do |n|
    "Foo bar #{n}"
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :builder, :class => Base::Builder do
    company_name { generate(:name) }
  end

  factory :user do
    builder
    email
  end

  factory :client do
    builder
  end

  factory :vendor do
    builder
  end
end