class PurchaseOrder < ActiveRecord::Base
  include Purchasable

  has_one :bill, :dependent => :destroy

  attr_accessible :chosen

  after_initialize :default_values

  validates_presence_of :categories_template, :project

  before_save :unset_actual_costs, :set_actual_costs
  after_save :create_bill
  before_destroy :raise_readonly, :unset_actual_costs

  def readonly?
    bill.try(:paid)
  end

  private
  def default_values
    self.chosen ||= true
    self.sales_tax_rate||=8.25
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

  def create_bill
    unless bill.present?
      Bill.create!(:purchase_order_id => self.id, :builder_id => self.builder_id)
    end
  end

  def raise_readonly
    raise ActiveRecord::ReadOnlyRecord if self.readonly?
  end
end
