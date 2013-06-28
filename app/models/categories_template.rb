class CategoriesTemplate < ActiveRecord::Base
  attr_accessible :category_id, :template_id, :items_attributes

  belongs_to :template
  belongs_to :category
  has_and_belongs_to_many :items
  accepts_nested_attributes_for :items, allow_destroy: true
end
