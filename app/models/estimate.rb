class Estimate < ActiveRecord::Base
  CURRENT = 'Current Estimate'
  PAST =  'Past Estimate'
  GUARANTEED = 'Guaranteed Bid'
  COST_PLUS ='Cost Plus Bid'
  acts_as_paranoid

  # mount_uploader :data, DataUploader
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :project
  has_many :measurements , :dependent => :destroy
  has_one :template, :dependent => :destroy
  has_many :invoices, :dependent => :destroy
  has_many :bids, :dependent => :destroy
  has_many :specifications, :dependent => :destroy
  has_many :bills, :dependent => :destroy
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
    bills.any? || invoices.any?
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

  def destroy_with_associations
    return false if check_destroyable == false
    template.categories_templates.each do |ct|
      ct.items.each do |i|
        i.destroy
      end
      ct.purchase_orders.each do |po|
        if po.bill
          po.bill.payments.each do |p|
            p.destroy
          end
          po.bill.payments_bills.destroy_all
          po.bill.delete
        end
        po.delete
      end
      ct.bills.each do |b|
        b.payments.each do |p|
          p.destroy
        end
        b.payments_bills.destroy_all
        b.delete
      end
      ct.category.delete if ct.category.present? && !ct.purchased
      ct.delete
    end
    template.delete
    invoices.each do |i|
      i.invoices_items.destroy_all
      i.invoices_bills_categories_templates.destroy_all
      i.receipts.each do |r|
        r.receipts_items.destroy_all
        r.deposits.each do |d|
          d.destroy
        end
        r.deposits_receipts.destroy_all
        r.delete
      end
      i.receipts_invoices.destroy_all
      i.delete
    end
    delete
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
