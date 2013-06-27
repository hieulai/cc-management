class Template < ActiveRecord::Base
  belongs_to :builder
  belongs_to :estimate
  # has_many :to_do_lists, class_name: 'ToDoList', through: :to_do_list_users, source: :to_do_list
  has_many :categories_templates
  has_many :categories, class_name: 'Category', through: :categories_templates, source: :category
  has_many :items, class_name: 'Item', through: :categories_templates, source: :item

  attr_accessible :name, :cost_total, :margin_total, :price_total, :default, :categories_attributes

  accepts_nested_attributes_for :categories, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
end