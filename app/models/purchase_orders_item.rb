class PurchaseOrdersItem < ActiveRecord::Base
  include Purchasable

  belongs_to :purchase_order
  attr_accessible :purchase_order_id

  after_destroy :check_to_destroy_payment

  private
  def check_to_destroy_payment
    if purchase_order.purchase_orders_items.empty? && item.change_orders_category
      purchase_order.bill.payments.each do |p|
        if p.bills.size > 1
          p.payments_bills.where(:bill_id => purchase_order.bill.id).destroy_all
        else
          p.destroy
        end
      end
      purchase_order.destroy
    end
  end
end
