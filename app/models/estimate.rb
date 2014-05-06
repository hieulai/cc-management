class Estimate < ActiveRecord::Base
  before_destroy :check_destroyable

  # mount_uploader :data, DataUploader
  belongs_to :builder, :class_name => "Base::Builder", :class_name => "Base::Builder"
  belongs_to :project
  has_many :measurements , :dependent => :destroy
  has_one :template, :dependent => :destroy
  has_many :invoices, :dependent => :destroy

  scope :current, where(status: "Current Estimate")
  scope :past, where(status: "Past Estimate")

  accepts_nested_attributes_for :measurements

  attr_accessible :progress, :status, :data,
  :deadline, :revenue, :profit, :margin, :notes, :project_id, :measurements_attributes, :builder_id, :kind

  validates_presence_of :project, :builder

  def undestroyable?
    template.undestroyable?
  end

  def kind
    read_attribute(:kind) || "Guaranteed Bid"
  end

  def cost_plus_bid?
    kind == "Cost Plus Bid"
  end

  def destroy_with_associations
    return false if check_destroyable == false
    return false if template.check_destroyable == false
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
      i.invoices_bills.destroy_all
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
      errors[:base] << "Estimate #{id} cannot be deleted once containing items which are added to an invoice"
      false
    end
  end
end
