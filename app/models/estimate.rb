# == Schema Information
#
# Table name: estimates
#
#  id         :integer          not null, primary key
#  builder_id :integer
#  project_id :integer
#  progress   :string(255)
#  status     :string(255)      default("Current Estimate")
#  deadline   :date
#  revenue    :decimal(10, 2)
#  profit     :decimal(10, 2)
#  margin     :decimal(10, 2)
#  notes      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  kind       :string(255)
#  deleted_at :time
#  committed  :boolean
#

class Estimate < ActiveRecord::Base
  CURRENT = 'Current Estimate'
  PAST =  'Past Estimate'
  GUARANTEED = 'Guaranteed Bid'
  COST_PLUS ='Cost Plus Bid'
  acts_as_paranoid

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :project
  has_many :measurements , :dependent => :destroy
  has_one :template, :dependent => :destroy
  has_many :invoices, :dependent => :destroy
  has_many :bids, :dependent => :destroy
  has_many :specifications, :dependent => :destroy
  has_many :bills, :dependent => :destroy
  has_many :receipts, :dependent => :destroy
  has_many :purchase_orders, :dependent => :destroy

  scope :current, where(status: CURRENT)
  scope :current_project, joins(:project).where("projects.status = ?", Project::CURRENT)
  scope :past, where(status: PAST)
  scope :commitments, where(committed: true)

  attr_accessible :progress, :status, :deadline, :revenue, :profit, :margin, :notes, :project_id, :measurements_attributes, :builder_id, :kind, :committed
  accepts_nested_attributes_for :measurements

  validates_presence_of :project, :builder

  before_save :check_commitment, :if => Proc.new { |e| e.committed && !e.committed_was }
  before_destroy :check_destroyable, :prepend => true

  def undestroyable?
    bills.any? || invoices.any? || receipts.any?
  end

  def kind
    read_attribute(:kind) || GUARANTEED
  end

  def cost_plus_bid?
    kind == COST_PLUS
  end

  def cos_categories
    categories = Category.where(:id => template.categories_templates.pluck(:category_id))
    co_categories = ChangeOrdersCategory.where(:change_order_id => project.change_orders.approved.pluck(:id)).uniq
    cos_categories = co_categories.map(&:category).uniq
    cos_categories.reject! { |c| categories.pluck(:name).include? c.name } || Array.new
  end

  private
  def check_destroyable
    if undestroyable?
      errors[:base] << "This estimate has bills, invoices or receipts attached to it. These items must be reallocated to another estimate before this one can be deleted."
      false
    end
  end

  def check_commitment
    if self.project.estimates.commitments.any?
      errors.add(:committed, "can not be set more than one estimate")
      false
    end
  end

end
