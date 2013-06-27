class CategoriesTemplate < ActiveRecord::Base
  attr_accessible :category_id, :template_id

  belongs_to :template
  belongs_to :category
  has_and_belongs_to_many :items
end
