class ChangeOrdersCategory < ActiveRecord::Base
  belongs_to :change_order
  belongs_to :category

  has_many :items, :dependent => :delete_all
  attr_accessible :category_id, :change_order_id, :items_attributes
  accepts_nested_attributes_for :items, allow_destroy: true
end
