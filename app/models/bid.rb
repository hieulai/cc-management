class Bid < ActiveRecord::Base
  belongs_to :project
  belongs_to :vendor
  belongs_to :categories_template

  validates_presence_of :categories_template

  attr_accessible :amount, :notes, :chosen, :categories_template_id, :vendor_id

  serialize :amount

  before_save :unset_committed_costs, :set_committed_costs

  before_destroy :unset_committed_costs

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

  def set_committed_costs
    self.amount.each do |i|
      if self.chosen
        item = Item.find(i[:id])
        if item.present?
          updated_cost = item.committed_cost.to_f + i[:uncommitted_cost].to_f
          item.update_attribute(:committed_cost, updated_cost == 0 ? nil : updated_cost)
        end
      end
    end
  end

  def unset_committed_costs
    self.amount_was.try(:each) do |i|
      if self.chosen_was
        item = Item.find(i[:id])
        if item.present?
          updated_cost = item.committed_cost.to_f - i[:uncommitted_cost].to_f
          item.update_attribute(:committed_cost, updated_cost == 0 ? nil : updated_cost)
        end
      end
    end
  end
end
