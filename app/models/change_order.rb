class ChangeOrder < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :project
  has_many :change_orders_categories, :dependent => :destroy

  scope :approved, -> { where approved: true }

  attr_accessible :name, :notes, :approved, :builder_id, :project_id
  accepts_nested_attributes_for :change_orders_categories, reject_if: :all_blank, allow_destroy: true

  before_save :check_destroyable, :if => :approved_changed?
  before_destroy :check_destroyable, :prepend => true
  after_initialize :default_values

  validates :name, presence: true

  def amount
    change_orders_categories.map(&:amount).compact.sum
  end

  def undestroyable?
    change_orders_categories.select { |ct| ct.undestroyable? }.any?
  end

  def has_paid_item?
    change_orders_categories.select { |ct| ct.has_paid_item? }.any?
  end

  private
  def check_destroyable
    if  undestroyable?
      errors[:base] << "This change order cannot be disapproved/deleted once containing items which are added to an invoice or a bill"
      false
    end
  end

  def default_values
    approved||= true
  end
end
