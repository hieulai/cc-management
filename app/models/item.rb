class Item < ActiveRecord::Base
  # belongs_to :template
  belongs_to :builder
  has_and_belongs_to_many :categories
  has_many :categories_templates, through: :categories_templates_items
  has_many :templates, through: :categories_templates_items

  attr_accessible :name, :description, :qty, :unit, :cost, :margin, :price, :default, :notes, :file

  validates :name, presence: true

  def price
    #if cost ! nil & margin ! nil
     # cost + margin
    #else cost ! nil & margin = nil
     # cost
    #else
     # 0
    #end
  end

  def self.to_csv(items)
    CSV.generate do |csv|
      csv << column_names
      items.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      product = find_by_id(row["id"]) || new
      product.attributes = row.to_hash.slice(*accessible_attributes)
      product.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file[:data].original_filename)
    when ".csv" then CSV.new(file[:data].tempfile)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file[:data].original_filename}"
    end
  end
end
