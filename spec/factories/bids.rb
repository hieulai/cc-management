# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bid do
    builder
    estimate
    category
    factory :chosen_bid do
      chosen true
    end
  end

  factory :bids_item do
    bid
  end
end
