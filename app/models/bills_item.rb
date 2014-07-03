class BillsItem < ActiveRecord::Base
  acts_as_paranoid
  include Purchasable

  belongs_to :bills_categories_template
  scope :has_actual_cost, where('actual_cost is NOT NULL')

  after_destroy :check_to_destroy_payment

  private
  def check_to_destroy_payment
    bill = bills_categories_template.bill
    if bill.categories_templates.empty? && item.change_orders_category
      bill.payments.each do |p|
        if p.bills.size > 1
          p.payments_bills.where(:bill_id => bill.id).destroy
        else
          p.destroy
        end
      end
      bill.destroy
    end
  end

end
