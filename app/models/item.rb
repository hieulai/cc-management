class Item < ActiveRecord::Base
  # belongs_to :template
  belongs_to :builder
  belongs_to :category
  has_many :categories_templates, through: :categories_templates_items
  has_many :templates, through: :categories_templates_items
  has_and_belongs_to_many :categories_templates

  attr_accessible :name, :description, :qty, :unit, :cost, :margin, :default, :notes, :file

  validates :name, presence: true

  scope :search, lambda{|query| where("name ILIKE ? OR description ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%")}

  HEADERS = ["Name", "Description", "Cost", "Unit", "Margin", "Price", "Notes"]
  after_initialize :default_values

  def price
    self.margin ||= 0
    self.amount + self.margin
  end

  def amount
    self.qty ||= 1
    self.cost ||= 0
    self.cost * self.qty
  end

  def self.to_csv(items, options = {})
    CSV.generate(options = {}) do |csv|
      csv << HEADERS
      items.each do |item|
        csv << [item.name, item.description, item.cost, item.unit, item.margin, item.price, item.notes]
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

  private
  def default_values
    self.qty ||= 1
    self.cost ||= 0
    self.margin ||= 0
  end
end
