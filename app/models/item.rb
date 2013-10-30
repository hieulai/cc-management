class Item < ActiveRecord::Base
  include Importable

  # belongs_to :template
  belongs_to :builder
  belongs_to :category
  belongs_to :purchase_order
  belongs_to :bill
  belongs_to :change_orders_category
  has_many :categories_templates, through: :categories_templates_items
  has_many :templates, through: :categories_templates_items
  has_and_belongs_to_many :categories_templates

  attr_accessible :name, :description, :qty, :unit, :estimated_cost, :actual_cost, :committed_cost, :margin, :default, :notes, :file, :change_order, :client_billed, :markup, :purchase_order_id, :bill_id

  validates :name, presence: true

  before_save :reset_markup

  scope :search, lambda{|query| where("name ILIKE ? OR description ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%")}

  HEADERS = ["Name", "Description", "Estimated_cost", "Unit", "Margin", "Price", "Notes"]
  after_initialize :default_values

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

  def self.to_csv(items, options = {})
    CSV.generate(options = {}) do |csv|
      csv << HEADERS
      items.each do |item|
        csv << [item.name, item.description, item.estimated_cost, item.unit, item.markup, item.price, item.notes]
      end
    end
  end

  def reset_markup
     if read_attribute(:margin).presence
        self.markup = nil
     end
  end

  private
  def default_values
    self.qty ||= 1
    self.estimated_cost ||= 0
  end
end
