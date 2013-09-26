class Bid < ActiveRecord::Base
  belongs_to :project
  belongs_to :vendor
  belongs_to :categories_template

  validates_presence_of :categories_template

  attr_accessible :amount, :notes, :chosen, :categories_template_id, :vendor_id

  serialize :amount

  before_save :set_committed_costs, :unset_chosen_other_bids

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

  def set_committed_costs (p = true)
    self.amount.each do |i|
      if self.chosen
        cost = p ? i[:uncommitted_cost] : nil
        if Item.exists?(i[:id])
          Item.find(i[:id]).update_attribute(:committed_cost, cost )
        end
      end
    end
  end

  def unset_chosen_other_bids
    if self.chosen
      self.categories_template.bids.each do |bid|
        if bid.id != self.id
          bid.update_attribute(:chosen, false)
        end
      end
    end
  end

  def unset_committed_costs
    set_committed_costs false
  end
end
