# == Schema Information
#
# Table name: purchase_orders
#
#  id                  :integer          not null, primary key
#  project_id          :integer
#  vendor_id           :integer
#  notes               :text
#  chosen              :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  sales_tax_rate      :decimal(10, 4)
#  shipping            :decimal(10, 2)
#  date                :date
#  builder_id          :integer
#  due_date            :date
#  cached_total_amount :decimal(10, 2)
#  payer_id            :integer
#  payer_type          :string(255)
#  deleted_at          :time
#  estimate_id         :integer
#

class PurchaseOrder < ActiveRecord::Base
  acts_as_paranoid
  include Cacheable

  belongs_to :estimate
  belongs_to :vendor
  belongs_to :payer, polymorphic: true
  belongs_to :builder, :class_name => "Base::Builder"

  has_one :bill, :dependent => :destroy
  has_many :purchase_orders_categories_templates, :dependent => :destroy
  has_many :categories_templates, :through => :purchase_orders_categories_templates

  default_scope order("date DESC")

  attr_accessible :chosen, :sales_tax_rate, :shipping, :date, :notes, :cached_total_amount, :builder_id, :project_id, :estimate_id,
                  :vendor_id, :due_date, :payer_id, :payer_type, :purchase_orders_categories_templates_attributes
  accepts_nested_attributes_for :purchase_orders_categories_templates, :allow_destroy => true

  before_save :check_zero_amount, :check_total_amount_changed
  before_destroy :check_destroyable, :prepend => true
  after_initialize :default_values
  after_save :create_default_bill, :update_indexes

  validates_presence_of :payer_id, :payer_type, :estimate, :date

  searchable do
    integer :id
    integer :builder_id
    date :date
    float :amount do
      total_amount
    end
    string :notes
    string :project_name do
      project_name
    end
    string :payer_name do
      payer_name
    end
    string :category_names do
      category_names
    end

    text :notes
    text :id_t do |po|
      po.id.to_s
    end
    text :amount_t do
      sprintf('%.2f', total_amount.to_f)
    end
    text :date_t do |po|
      po.date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :project_names do
      project_name
    end
    text :payer_name do
      payer_name
    end
    text :category_names do
      category_names
    end
  end

  def project
    estimate.try(:project)
  end

  def project_name
    project.try(:name)
  end

  def payer_name
    payer.try(:display_name)
  end

  def category_names
    categories.map { |c| c.name }.join(",")
  end

  def categories
    categories_templates.map { |ct| ct.category }
  end

  def has_bill_paid?
    bill.try(:paid?)
  end

  def has_bill_full_paid?
    bill.try(:full_paid?)
  end

  def total_amount
    purchase_orders_categories_templates.reject(&:marked_for_destruction?).map(&:amount).compact.sum + shipping.to_f
  end

  def purchasable_items
    r = []
    purchase_orders_categories_templates.each do |p_ct|
      r << p_ct.purchase_orders_items
    end
    r.flatten
  end

  private
  def default_values
    self.chosen ||= true
    self.sales_tax_rate||=8.25
    self.cached_total_amount||=0
  end

  def create_default_bill
    self.create_bill({:purchase_order_id => self.id, :builder_id => self.builder_id, :billed_date => self.date}) unless bill
    bill.update_attributes({:payer_id => payer_id, :payer_type => payer_type, :estimate_id => estimate_id, :billed_date => self.date})
  end

  def check_destroyable
    if has_bill_paid?
      errors[:base] << "This purchase order is already paid and can not be deleted."
      false
    end
  end

  def check_zero_amount
    if total_amount.to_f == 0
      errors[:base] << "Can not save a $0 Purchase order"
      false
    end
  end

  def check_total_amount_changed
    if !self.new_record? && self.has_bill_paid? && self.total_amount!= self.cached_total_amount
      errors[:base] << "This purchase order has bill #{bill.id} which has already been paid in the amount of $#{cached_total_amount}. Editing a paid bill requires that all item amounts continue to add up to the original payment amount. If the original payment was made for the wrong amount, correct the payment first and then come back and edit the bill."
      return false
    else
      self.cached_total_amount+= self.shipping.to_f
    end
  end

  def update_indexes
    Sunspot.delay.index bill
  end
end
