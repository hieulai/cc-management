module Purchasable
  extend ActiveSupport::Concern

  included do
    belongs_to :item

    attr_accessible :description, :qty, :estimated_cost, :actual_cost, :item_id
    before_save :unset_actual_costs, :set_actual_costs
    before_destroy :unset_actual_costs

    def set_actual_costs
      updated_cost = self.item.actual_cost.to_f + self.actual_cost.to_f
      unless self.item.update_attribute(:actual_cost, updated_cost)
        errors[:base] << item.errors.full_messages.join(".")
        return false
      end
    end

    def unset_actual_costs
      updated_cost = self.item.actual_cost.to_f - self.actual_cost_was.to_f
      self.item.update_column(:actual_cost, updated_cost == 0 ? nil : updated_cost)
    end
  end

end