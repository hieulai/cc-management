class PurchaseOrder < ActiveRecord::Base
  belongs_to :project
  belongs_to :vendor
  belongs_to :categories_template
  belongs_to :builder

  has_many :items, :dependent => :destroy

  validates_presence_of :categories_template, :project

  attr_accessible :amount, :notes, :chosen, :builder_id,  :project_id, :categories_template_id, :vendor_id, :sales_tax_rate, :shipping, :date

  serialize :amount

  before_save :unset_actual_costs, :set_actual_costs

  before_destroy :unset_actual_costs

  after_initialize :default_values

  def total_amount
    t=0
    self.shipping||=0
    amount.each do |i|
      t+= i[:actual_cost].to_f
    end
    t + items.map(&:actual_cost).compact.sum + self.shipping;
  end

  def item_amount(item_id)
    self.amount.try(:each) do |i|
      if item_id.to_s == i[:id]
        return i[:estimated_cost].to_f * i[:qty].to_f
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
      if self.chosen && Item.exists?(i[:id])
        item = Item.find(i[:id])
        updated_cost = item.actual_cost.to_f + i[:actual_cost].to_f
        item.update_attribute(:actual_cost, updated_cost == 0 ? nil : updated_cost)
      end
    end
  end

  def unset_actual_costs
    self.amount_was.try(:each) do |i|
      if self.chosen && Item.exists?(i[:id])
        item = Item.find(i[:id])
        updated_cost = item.actual_cost.to_f - i[:actual_cost].to_f
        item.update_attribute(:actual_cost, updated_cost == 0 ? nil : updated_cost)
      end
    end
  end

  private
  def default_values
    self.chosen ||= true
    self.sales_tax_rate||=8.25
  end
end
