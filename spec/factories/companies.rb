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

  #InvoicesBillsCategoriesTemplate.joins(:invoice).where("invoices.bill_from_date is not null AND invoices.bill_to_date is not null").select do |ibct|
  #  !ibct.bills_categories_template.bill.billed_date.between?(ibct.invoice.bill_from_date, ibct.invoice.bill_to_date)
  #end.each {|ibct| ibct.destroy }
  #
  #Invoice.all.each { |i| i.update_column(:cached_total_amount, i.total_amount) }

end
