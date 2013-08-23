class Bid < ActiveRecord::Base
  belongs_to :project
  belongs_to :vendor
  belongs_to :categories_template

  validates_presence_of :categories_template

  attr_accessible :amount, :notes, :chosen, :categories_template_id, :vendor_id

  serialize :amount

  before_save :set_committed_cost

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
  end

  def set_committed_cost
    self.amount.each do |i|
      cost = self.chosen ? i[:uncommitted_cost] : nil
      Item.find(i[:id]).update_attribute(:committed_cost, cost )
    end
  end
end
