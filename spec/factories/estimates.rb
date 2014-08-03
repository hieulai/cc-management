# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :estimate do
    builder
    project
    factory :guaranteed_bid_estimate do
      kind Estimate::GUARANTEED
    end
    factory :cost_plus_bid_estimate do
      kind Estimate::COST_PLUS
    end
    factory :has_bills_estimate,  traits: [:has_bills]
    factory :has_invoices_estimate, traits: [:has_invoices]
    factory :committed_estimate do
      committed true
    end
  end
end
