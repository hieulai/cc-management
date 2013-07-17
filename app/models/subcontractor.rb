class Subcontractor < ActiveRecord::Base
  
  belongs_to :builder
  attr_accessible :company,:first_name,:last_name,:email,:primary_phone,:secondary_phone,:website,:address,:city,:state,:zipcode,:notes, 
  :trade, :primary_phone_tag, :secondary_phone_tag, :file
  
  scope :search, lambda{|query| where("company ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR notes ILIKE ? OR trade ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")} 
  
  HEADERS = ["Trade", "Company", "First Name", "Primary Phone", "Email", "Notes"]
  
  def full_name
     "#{first_name} #{last_name}"
  end
  
  def self.to_csv(subcontractors, options = {})
    CSV.generate(options = {}) do |csv|
      csv << HEADERS
      subcontractors.each do |subcontractor|
        csv << [subcontractor.trade, subcontractor.company, subcontractor.first_name, subcontractor.primary_phone, subcontractor.email, 
          subcontractor.notes]
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
      subcontractor = find_by_id(row["id"]) || new
      subcontractor.attributes = row.to_hash.slice(*accessible_attributes)
      subcontractor.builder_id = builder.id
      unless subcontractor.save
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

end
