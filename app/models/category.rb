class Category < ActiveRecord::Base
  belongs_to :builder
  has_many :categories_templates
  has_many :templates, through: :categories_templates
  has_many :items
  # has_and_belongs_to_many :items

  attr_accessible :name, :cost_total, :margin_total, :price_total, :default, :items_attributes

  accepts_nested_attributes_for :items, reject_if: :all_blank, allow_destroy: true

  # accepts_nested_attributes_for :items, allow_destroy: true

  validates :name, presence: true

  before_destroy do
    categories_templates.each do |ct|
      ct.destroy
    end
  end
end
