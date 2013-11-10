class Bid < ActiveRecord::Base
  before_destroy :check_readonly, :unset_committed_costs

  belongs_to :project
  belongs_to :vendor
  belongs_to :categories_template

  has_one :bill, :dependent => :destroy

  validates_presence_of :categories_template

  attr_accessible :amount, :notes, :chosen, :categories_template_id, :vendor_id, :due_date

  serialize :amount

  before_save :check_readonly, :unset_committed_costs, :set_committed_costs, :update_bill

  def has_bill_paid?
    bill.try(:paid?)
  end

  def total_amount
    t=0
    amount.each do |i|
      t+= i[:'uncommitted_cost'].to_f
    end
    t
  end

  def item_amount(item_id)
    self.amount.each do |i|
      if item_id.to_s == i[:id]
        return i[:uncommitted_cost]
      end
    end
    return nil
  end

  private
  def set_committed_costs
    if self.chosen
      self.amount.each do |i|
        item = Item.find(i[:id])
        if item.present?
          updated_cost = item.committed_cost.to_f + i[:uncommitted_cost].to_f
          item.update_attribute(:committed_cost, updated_cost == 0 ? nil : updated_cost)
        end
      end
    end
  end

  def unset_committed_costs
    if self.chosen_was
      self.amount_was.try(:each) do |i|
        item = Item.find(i[:id])
        if item.present?
          updated_cost = item.committed_cost.to_f - i[:uncommitted_cost].to_f
          item.update_attribute(:committed_cost, updated_cost == 0 ? nil : updated_cost)
        end
      end
    end
  end

  def update_bill
    if chosen
      create_bill(builder_id: self.project.builder_id, vendor_id: vendor_id ) unless bill.present?
    elsif bill.present?
      return false if check_readonly == false
      bill.destroy
    end
  end

  def check_readonly
    if has_bill_paid?
      errors[:base] << "This record is readonly"
      false
    end
  end
end
