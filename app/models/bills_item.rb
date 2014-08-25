# == Schema Information
#
# Table name: bills_items
#
#  id                           :integer          not null, primary key
#  item_id                      :integer
#  description                  :string(255)
#  qty                          :decimal(10, 2)
#  amount                       :decimal(10, 2)
#  estimated_cost               :decimal(10, 2)
#  actual_cost                  :decimal(10, 2)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  memo                         :text
#  deleted_at                   :time
#  bills_categories_template_id :integer
#

class BillsItem < ActiveRecord::Base
  acts_as_paranoid
  include Purchasable

  belongs_to :bills_categories_template
  scope :has_actual_cost, where('actual_cost is NOT NULL')
  scope :bill, lambda { |bill_id| joins(:bills_categories_template).where('bills_categories_templates.bill_id = ?', bill_id) }
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
