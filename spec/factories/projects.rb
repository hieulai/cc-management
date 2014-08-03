# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    builder
    client
    name { generate(:name) }
    factory :has_undestroyable_estimates_project do
      after(:create) do |project, evaluator|
        project.estimates << FactoryGirl.create(:has_bills_estimate)
        project.estimates << FactoryGirl.create(:has_invoices_estimate)
      end
    end

    factory :has_estimates_project do
      factory :current_project do
        status Project::CURRENT
        after(:build) do |project, evaluator|
          project.estimates << FactoryGirl.create(:committed_estimate)
        end
      end

      factory :current_lead_project do
        status Project::CURRENT_LEAD
        factory :current_lead_has_estimates_project do
          after(:build) do |project, evaluator|
            project.estimates << FactoryGirl.create(:estimate)
          end
        end

      end
    end
  end
end
