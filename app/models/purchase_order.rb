class PurchaseOrder < ActiveRecord::Base
  belongs_to :project
  belongs_to :vendor
  belongs_to :categories_template
  belongs_to :builder

  has_many :items, :dependent => :destroy

  validates_presence_of :categories_template, :project

  attr_accessible :amount, :notes, :chosen, :builder_id,  :project_id, :categories_template_id, :vendor_id, :sales_tax, :shipping, :date

  serialize :amount

  before_save :unset_actual_costs, :set_actual_costs, :unset_chosen_other_pos

  before_destroy :unset_actual_costs

  after_initialize :default_values

  def total_amount
    t=0
    self.sales_tax||=0
    self.shipping||=0
    amount.each do |i|
      t+= i[:actual_cost].to_f
    end
    t+= self.sales_tax + self.shipping + items.map(&:actual_cost).sum
  end

  def item_amount(item_id)
    self.amount.try(:each) do |i|
      if item_id.to_s == i[:id]
        return i[:actual_cost]
      end
    end
    return nil
  end

  def item_chosen(item_id)
    if Item.exists?(item_id)
      self.amount.try(:each) do |i|
        if item_id.to_s == i[:id]
          return true
        end
      end
      return false
    end
  end

  def item_qty(item_id)
    if Item.exists?(item_id)
      self.amount.try(:each) do |i|
        if item_id.to_s == i[:id]
          return i[:qty]
        end
      end
      return Item.find(item_id).qty
    end
  end

  def item_estimated_cost(item_id)
    if Item.exists?(item_id)
      self.amount.try(:each) do |i|
        if item_id.to_s == i[:id]
          return i[:estimated_cost]
        end
      end
     return Item.find(item_id).estimated_cost
    end
  end

  def set_actual_costs
    self.amount.try(:each) do |i|
      if self.chosen
        if Item.exists?(i[:id])
          Item.find(i[:id]).update_attribute(:actual_cost, i[:actual_cost] )
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
    self.amount_was.try(:each) do |i|
      if self.chosen
        if Item.exists?(i[:id])
          Item.find(i[:id]).update_attribute(:actual_cost, nil )
        end
      end
    end
  end

  private
  def default_values
    self.chosen ||= true
  end
end
