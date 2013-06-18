class Template < ActiveRecord::Base
  belongs_to :builder
  belongs_to :estimate
  has_many :categories

  attr_accessible :name, :cost_total, :margin_total, :price_total, :default, :categories_attributes

  accepts_nested_attributes_for :categories, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
end
