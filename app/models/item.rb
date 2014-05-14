class Item < ActiveRecord::Base
  acts_as_paranoid
  include Importable
  include Invoiceable

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
  has_many :bids_items, :dependent => :destroy

  counter_culture :bill, :column_name => "cached_total_amount", :delta_column => 'actual_cost'
  counter_culture :purchase_order, :column_name => "cached_total_amount", :delta_column => 'actual_cost'

  attr_accessible :name, :description, :qty, :unit, :estimated_cost, :actual_cost, :committed_cost, :margin, :default, :notes, :file, :change_order, :client_billed, :markup, :bill_memo, :purchase_order_id, :bill_id, :builder_id
  validates :name, presence: true

  before_save :check_readonly, :if => :changed? , :unless => Proc.new { |i| i.changes.size == 1 && i.actual_cost_changed? || i.committed_cost_changed? }
  before_save :reset_markup
  after_initialize :default_values

  default_scope order("name ASC")
  scope :search_by_name, lambda { |q| where("name ILIKE ?", '%'+ q + '%') }

  HEADERS = ["Name", "Description", "Estimated_cost", "Unit", "Margin", "Price", "Notes"]

  searchable do
    text :name, :description, :unit, :price, :notes
    text :qty_t do
      sprintf('%.2f', qty.to_f)
    end
    text :estimated_cost_t do
      sprintf('%.2f', estimated_cost.to_f)
    end
    text :markup_t do
      sprintf('%.2f', markup.to_f)
    end
    text :price_t do
      sprintf('%.2f', price.to_f)
    end
    integer :qty
    integer :builder_id
  end

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

  def actual_cost
    if bills_items.any? || purchase_orders_items.any?
      bills_items.sum(&:actual_cost).to_f + purchase_orders_items.sum(&:actual_cost).to_f
    elsif bill || purchase_order || new_record?
      read_attribute(:actual_cost)
    end
  end

  def committed_cost
    bids_items.map(&:amount).compact.sum if bids_items.any?
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

  def bid_item(bid_id)
    self.bids_items.where(:bid_id => bid_id).first
  end

  def purchased?
    self.purchase_order_id.present? || self.bill_id.present?
  end

  def from_change_order?
    self.change_orders_category.present?
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
end
