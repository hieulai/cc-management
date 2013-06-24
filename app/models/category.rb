class Category < ActiveRecord::Base
  belongs_to :builder
  has_and_belongs_to_many :template
  has_and_belongs_to_many :items

  attr_accessible :name, :cost_total, :margin_total, :price_total, :default, :items_attributes

  # accepts_nested_attributes_for :items, allow_destroy: true

  validates :name, presence: true, uniqueness: true
end
