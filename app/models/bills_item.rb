class BillsItem < ActiveRecord::Base
  acts_as_paranoid
  include Purchasable

  belongs_to :bill
  attr_accessible :bill_id
  counter_culture :bill, :column_name => "cached_total_amount", :delta_column => 'actual_cost'

  after_destroy :check_to_destroy_payment

  private
  def check_to_destroy_payment
    if bill.bills_items.empty? && item.change_orders_category
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
