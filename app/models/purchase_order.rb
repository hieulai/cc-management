class PurchaseOrder < ActiveRecord::Base
  belongs_to :project
  belongs_to :vendor
  belongs_to :categories_template

  validates_presence_of :categories_template

  attr_accessible :amount, :notes, :chosen, :categories_template_id, :vendor_id

  serialize :amount

  before_save :set_actual_costs, :unset_chosen_other_pos

  before_destroy :unset_actual_costs

  def total_amount
    t=0
    amount.each do |i|
      t+= i[:actual_cost].to_f
    end
    t
  end

  def item_amount(item_id)
    self.amount.each do |i|
      if item_id.to_s == i[:id]
        return i[:actual_cost]
      end
    end
  end

  def set_actual_costs (p = true)
    self.amount.each do |i|
      if self.chosen
        cost = p ? i[:actual_cost] : nil
        item = Item.find(i[:id])
        if item.present?
          item.update_attribute(:actual_cost, cost )
        end
      end
    end
  end

  def unset_chosen_other_pos
    if self.chosen
      self.categories_template.purchase_orders.each do |po|
        if po.id != self.id
          po.update_attribute(:chosen, false)
        end
      end
    end
  end

  def unset_actual_costs
    set_actual_costs false
  end
end
