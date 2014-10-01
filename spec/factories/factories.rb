FactoryGirl.define do
  sequence :name do |n|
    "Foo bar #{n}"
  end

  sequence :string do |n|
    "Lorem #{n}"
  end

  sequence :date do |n|
    Date.new(2000,12,31) + n.days
  end

  sequence :email do |n|
    "object#{n}@example.com"
  end

  sequence :payment_method do |n|
    Payment::METHODS[n % Payment::METHODS.length]
  end

  sequence :receipt_method do |n|
    Receipt::METHODS[n % Receipt::METHODS.length]
  end

  sequence :vendor_type do |n|
    Vendor::TYPES[n % Vendor::TYPES.length]
  end

  trait :has_projects do
    after(:create) do |object, evaluator|
      object.projects << FactoryGirl.build(:current_project)
    end
  end

  trait :has_payments do
    after(:create) do |object, evaluator|
      object.payments << FactoryGirl.build(:payment)
    end
  end

  trait :has_bills do
    after(:create) do |object, evaluator|
      object.bills << FactoryGirl.build(:bill)
    end
  end

  trait :has_paid_bills do
    after(:build) do |object, evaluator|
      object.bills << FactoryGirl.build(:paid_bill)
    end
  end

  trait :has_invoiced_bills do
    after(:build) do |object, evaluator|
      object.bills << FactoryGirl.build(:invoiced_bill)
    end
  end

  trait :has_deposits_receipts do
    after(:create) do |object, evaluator|
      object.deposits_receipts << FactoryGirl.build(:deposits_receipt)
    end
  end

  trait :has_receipts do
    after(:create) do |object, evaluator|
      object.receipts << FactoryGirl.build(:receipt)
    end
  end

  trait :has_invoices do
    after(:create) do |object, evaluator|
      object.invoices << FactoryGirl.build(:invoice)
    end
  end

  trait :has_purchase_orders do
    after(:create) do |object, evaluator|
      object.purchase_orders << FactoryGirl.build(:purchase_order)
    end
  end

  trait :has_bids do
    after(:create) do |object, evaluator|
      object.bids << FactoryGirl.build(:bid)
    end
  end
end