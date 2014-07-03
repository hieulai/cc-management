class PurchaseOrdersItem < ActiveRecord::Base
  include Purchasable

  belongs_to :purchase_orders_categories_template

  scope :has_actual_cost, where('actual_cost is NOT NULL')

  after_destroy :check_to_destroy_payment

  private
  def check_to_destroy_payment
    po = purchase_orders_categories_template.purchase_order
    if po.categories_templates.empty? && item.change_orders_category
      po.bill.payments.each do |p|
        if p.bills.size > 1
          p.payments_bills.where(:bill_id => po.bill.id).destroy_all
        else
          p.destroy
        end
      end
      po.destroy
    end
  end
end
