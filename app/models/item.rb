class Item < ActiveRecord::Base
  include Importable

  before_destroy :check_readonly

  # belongs_to :template
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :category
  belongs_to :purchase_order
  belongs_to :bill
  belongs_to :change_orders_category
  has_many :categories_templates, through: :categories_templates_items
  has_many :templates, through: :categories_templates_items
  has_many :invoices_items, :dependent => :destroy
  has_many :invoices, :through => :invoices_items
  has_and_belongs_to_many :categories_templates
  has_many :bills_items, :dependent => :destroy
  has_many :purchase_orders_items, :dependent => :destroy

  attr_accessible :name, :description, :qty, :unit, :estimated_cost, :actual_cost, :committed_cost, :margin, :default, :notes, :file, :change_order, :client_billed, :markup, :purchase_order_id, :bill_id
  validates :name, presence: true

  before_save :check_readonly, :if => :changed? , :unless => Proc.new { |i| i.changes.size == 1 && i.actual_cost_changed? || i.committed_cost_changed? }
  before_save :check_overpaid, :reset_markup
  after_initialize :default_values

  default_scope order("name ASC")
  scope :search, lambda{|query| where("name ILIKE ? OR description ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%")}
  scope :search_by_name, lambda { |q| where("name ILIKE ?", '%'+ q + '%') }

  HEADERS = ["Name", "Description", "Estimated_cost", "Unit", "Margin", "Price", "Notes"]

  def margin
    if read_attribute(:margin).present?
      read_attribute(:margin).presence
    else
      self.markup.present? ? self.markup * self.qty : 0
    end
  end

  def estimated_cost(a = false)
    unless purchase_order.present? || bill.present?
      read_attribute(:estimated_cost)
    else
      a ? read_attribute(:estimated_cost) : 0
    end
  end

  def price
    self.amount +  self.margin
  end

  def amount(a = false)
    self.estimated_cost(a) * self.qty
  end

  def committed_profit
    self.committed_cost.present? ? (self.amount - self.committed_cost) + self.margin : nil
  end

  def actual_profit
    self.actual_cost.present? ? (self.amount - self.actual_cost) + self.margin : nil
  end

  def prior_amount(invoice_id)
    previous_ii = InvoicesItem.where(:item_id => id)
    if invoice_id.present?
      first_ii = invoice_item(invoice_id)
      if first_ii.present?
        previous_ii = InvoicesItem.previous_created_by_item(id, first_ii.created_at)
      end
    end
    previous_ii.map(&:amount).compact.sum if previous_ii.any?
  end

  def invoice_amount
    invoices_items.map(&:amount).compact.sum if invoices_items.any?
  end

  def invoice_item(invoice_id)
    self.invoices_items.where(:invoice_id => invoice_id).first
  end

  def billed?
    self.invoices.any?
  end

  def billable?(invoice_id =nil, net = false)
    invoice_item(invoice_id).present? || invoice_amount.nil? || billable_amount(net) > 0
  end

  def billable_amount(net = false)
    (net ? amount.to_f : price.to_f) - invoice_amount.to_f
  end

  def self.to_csv(items, options = {})
    CSV.generate(options = {}) do |csv|
      csv << HEADERS
      items.each do |item|
        csv << [item.name, item.description, item.estimated_cost, item.unit, item.markup, item.price, item.notes]
      end
    end
  end

  private
  def reset_markup
    if read_attribute(:margin).presence
      self.markup = nil
    end
  end

  def default_values
    self.qty ||= 1
    self.estimated_cost ||= 0
  end

  def check_readonly
    if self.billed?
      errors[:base] << "Item #{name} cannot be edited/deleted once added to an invoice. Please delete invoice to edit item details"
      false
    end
  end

  def check_overpaid
    if self.actual_cost.present? && self.committed_cost.present? && (self.actual_cost > self.committed_cost)
      errors[:base] << "Total paid amount of item #{name}: $#{self.actual_cost} is greater than total bid amount: $#{self.committed_cost}"
      false
    end
  end
end
