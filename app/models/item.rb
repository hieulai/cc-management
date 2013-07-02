class Item < ActiveRecord::Base
  # belongs_to :template
  belongs_to :builder
  belongs_to :category
  has_many :categories_templates, through: :categories_templates_items
  has_many :templates, through: :categories_templates_items
  has_and_belongs_to_many :categories_templates

  attr_accessible :name, :description, :qty, :unit, :cost, :margin, :price, :default, :notes, :file

  validates :name, presence: true
  
  scope :search, lambda{|query| where("name LIKE ? OR description LIKE ? OR notes LIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%")} 

  def self.to_csv(builder, options = {})
    CSV.generate(options = {}) do |csv|
      csv << ["id", "name", "description", "cost", "margin"]
      builder.items.each_with_index do |item|
        csv << [item.id, item.name, item.description, item.cost, item.margin]
      end
    end
  end

  def self.import(file, builder)
    CSV.foreach(file.path, headers: true) do |row|
      item = find_by_id(row["id"]) || new
      item.attributes = row.to_hash.slice("name", "description", "cost", "margin")
      item.builder_id = builder.id
      item.save!
    end
  end

  def self.excel_import(file, builder)
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet.open file.path
    sheet1 = book.worksheet 0
    sheet1.each do |row|
      item = find_by_id(row["id"]) || new
      item.attributes = row.to_hash.slice("name", "description", "cost", "margin")
      item.builder_id = builder.id
      item.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then CSV.new(file.path, nil)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file[:data].original_filename}"
    end
  end
end
