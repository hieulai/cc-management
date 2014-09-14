module Purchasable
  extend ActiveSupport::Concern

  included do
    belongs_to :item

    attr_accessible :description, :qty, :estimated_cost, :actual_cost, :memo, :item_id
    before_save :compare_item_costs

    validate :presence_of_bill_memo
  end

  def bill_memo
    memo
  end

  def compare_item_costs
    update_cost = item.actual_cost.to_f + actual_cost.to_f - actual_cost_was.to_f
    if item.committed_cost.present? && (update_cost > item.committed_cost.to_f)
      errors[:bid_amount] << "Total paid amount of item #{item.name}: $#{update_cost} is greater than total bid amount: $#{item.committed_cost}"
      return false
    end
  end

  def presence_of_bill_memo
    if memo.blank?
      errors[:base] << "Bill memo of #{item.name} can't be blank"
    end
  end

end