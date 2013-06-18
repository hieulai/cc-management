class Category < ActiveRecord::Base
  belongs_to :builder
  belongs_to :template
  has_many :items

  attr_accessible :name, :cost_total, :margin_total, :price_total, :default, :items_attributes

  accepts_nested_attributes_for :items, allow_destroy: true
end
