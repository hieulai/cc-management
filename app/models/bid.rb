class Bid < ActiveRecord::Base
  before_destroy :unset_committed_costs

  belongs_to :project
  belongs_to :vendor
  belongs_to :category

  validates_presence_of :category

  attr_accessible :amount, :notes, :chosen, :vendor_id, :category_id

  serialize :amount

  before_save :unset_committed_costs, :set_committed_costs

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

  def items
    categories_template.try(:items)
  end

  def co_items
    if categories_template
      categories_template.co_items
    elsif category
      project.co_items(category)
    end
  end

  private
  def set_committed_costs
    if self.chosen
      self.amount.each do |i|
        if Item.exists?(i[:id])
          item = Item.find(i[:id])
          updated_cost = item.committed_cost.to_f + i[:uncommitted_cost].to_f
          item.update_attribute(:committed_cost, updated_cost == 0 ? nil : updated_cost)
        end
      end
    end
  end

  def unset_committed_costs
    if self.chosen_was
      self.amount_was.try(:each) do |i|
        if Item.exists?(i[:id])
          item = Item.find(i[:id])
          updated_cost = item.committed_cost.to_f - i[:uncommitted_cost].to_f
          item.update_attribute(:committed_cost, updated_cost == 0 ? nil : updated_cost)
        end
      end
    end
  end

  def categories_template
    CategoriesTemplate.where(:category_id => category_id, :template_id => project.estimates.first.template.id).first
  end
end
