class Item < ActiveRecord::Base
  # belongs_to :template
  belongs_to :builder
  belongs_to :category
  belongs_to :purchase_order
  has_many :categories_templates, through: :categories_templates_items
  has_many :templates, through: :categories_templates_items
  has_and_belongs_to_many :categories_templates

  attr_accessible :name, :description, :qty, :unit, :estimated_cost, :actual_cost, :committed_cost, :margin, :default, :notes, :file, :change_order, :client_billed, :markup, :purchase_order_id

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
    unless purchase_order.present?
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

  def self.import(file, builder)
    spreadsheet = open_spreadsheet(file)
    if spreadsheet.first_row.nil?
      raise "There is no data in file"
    end
    header = spreadsheet.row(1).map! { |c| c.downcase.strip }
    errors = []
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      item = find_by_id(row["id"]) || new
      item.attributes = row.to_hash.slice(*accessible_attributes)
      item.builder_id = builder.id
      unless item.save
        errors << "Importing Error at line #{i}: #{item.errors.full_messages}"
      end
    end
    return errors
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path,nil)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file[:data].original_filename}"
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
