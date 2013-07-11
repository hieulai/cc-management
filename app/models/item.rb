class Item < ActiveRecord::Base
  # belongs_to :template
  belongs_to :builder
  belongs_to :category
  has_many :categories_templates, through: :categories_templates_items
  has_many :templates, through: :categories_templates_items
  has_and_belongs_to_many :categories_templates

  attr_accessible :name, :description, :qty, :unit, :cost, :margin, :default, :notes, :file

  validates :name, presence: true
  
  scope :search, lambda{|query| where("name LIKE ? OR description LIKE ? OR notes LIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%")}

  HEADERS = ["Name", "Description", "Cost", "Unit", "Margin", "Price", "Notes"]

  def price
    if cost && margin
      cost + margin
    elsif cost && margin.nil?
      cost
    elsif cost.nil? && margin
      margin
    elsif cost.nil? && margin.nil?
      0
    end
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
    header = spreadsheet.row(1).map!{|c| c.downcase.strip}
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      item = find_by_id(row["id"]) || new
      item.attributes = row.to_hash.slice(*accessible_attributes)
      item.builder_id = builder.id
      item.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path,nil)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file[:data].original_filename}"
    end
  end
end
