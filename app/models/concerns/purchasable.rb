module Purchasable
  extend ActiveSupport::Concern

  included do
    belongs_to :project
    belongs_to :vendor
    belongs_to :categories_template
    belongs_to :builder, :class_name => "Base::Builder"

    has_many :items, :dependent => :destroy

    attr_accessible :amount, :notes, :builder_id, :project_id, :categories_template_id, :vendor_id, :due_date, :category_id
    attr_accessor :category_id
    serialize :amount

    before_save :unset_actual_costs, :set_actual_costs

    before_destroy :unset_actual_costs

    after_destroy :destroy_purchased_categories_template

    validates_presence_of :vendor, :project, :categories_template

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

    def item_description(item_id)
      if Item.exists?(item_id)
        self.amount.try(:each) do |i|
          if item_id.to_s == i[:id]
            return i[:description]
          end
        end
        return Item.find(item_id).description
      end
    end

    def set_actual_costs
      self.amount.try(:each) do |i|
        if Item.exists?(i[:id])
          item = Item.find(i[:id])
          updated_cost = item.actual_cost.to_f + i[:actual_cost].to_f
          unless item.update_attribute(:actual_cost, updated_cost)
            errors[:base] << "Item #{item.name} is readonly"
            return false
          end
        end
      end
    end

    def unset_actual_costs
      self.amount_was.try(:each) do |i|
        if Item.exists?(i[:id])
          item = Item.find(i[:id])
          updated_cost = item.actual_cost.to_f - i[:actual_cost].to_f
          unless item.update_attribute(:actual_cost, updated_cost == 0 ? nil : updated_cost)
            errors[:base] << "Item #{item.name} is readonly"
            return false
          end
        end
      end
    end

    def destroy_purchased_categories_template
      if categories_template && categories_template.purchased && categories_template.bills.empty? && categories_template.purchase_orders.empty?
        categories_template.category.destroy
      end
    end
  end

end