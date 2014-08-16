# == Schema Information
#
# Table name: purchase_orders_items
#
#  id                                     :integer          not null, primary key
#  item_id                                :integer
#  description                            :string(255)
#  qty                                    :decimal(10, 2)
#  amount                                 :decimal(10, 2)
#  estimated_cost                         :decimal(10, 2)
#  actual_cost                            :decimal(10, 2)
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  memo                                   :text
#  purchase_orders_categories_template_id :integer
#  deleted_at                             :time
#

class PurchaseOrdersItem < ActiveRecord::Base
  acts_as_paranoid
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
