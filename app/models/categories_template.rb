class CategoriesTemplate < ActiveRecord::Base
  attr_accessible :category_id, :template_id, :items_attributes

  belongs_to :template
  belongs_to :category
  has_many :bids, :dependent => :delete_all
  has_and_belongs_to_many :items
  accepts_nested_attributes_for :items, allow_destroy: true

  def category_name
    self.category.name
  end

  before_destroy do
    items.destroy_all
  end
end
