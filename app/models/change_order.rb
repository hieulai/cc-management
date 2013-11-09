class ChangeOrder < ActiveRecord::Base
  before_destroy :check_destroyable

  belongs_to :builder
  belongs_to :project
  has_many :change_orders_categories, :dependent => :delete_all

  scope :approved, -> { where approved: true }

  attr_accessible :name, :notes, :approved, :builder_id, :project_id
  accepts_nested_attributes_for :change_orders_categories, reject_if: :all_blank, allow_destroy: true

  before_save :check_destroyable, :if => :approved_changed?

  validates :name, presence: true

  def amount
    change_orders_categories.map(&:amount).compact.sum
  end

  def undestroyable?
    change_orders_categories.select { |ct| ct.undestroyable? }.any?
  end

  private
  def check_destroyable
    if  undestroyable?
      errors[:base] << "Change Order #{name} cannot be disapproved/deleted once containing items which are added to an invoice"
      false
    end
  end
end
