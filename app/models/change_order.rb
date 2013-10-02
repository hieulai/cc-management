class ChangeOrder < ActiveRecord::Base
  belongs_to :builder
  belongs_to :project

  has_many :change_orders_categories, :dependent => :delete_all

  scope :approved, -> { where approved: true }

  validates :name, presence: true

  attr_accessible :name, :notes, :approved, :builder_id, :project_id
  accepts_nested_attributes_for :change_orders_categories, reject_if: :all_blank, allow_destroy: true

  def amount
    change_orders_categories.map(&:amount).compact.sum
  end
end
