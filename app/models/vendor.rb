class Vendor < ActiveRecord::Base
  belongs_to :builder
  
  attr_accessible :company,:vendor_type,:trade,:primary_first_name,:primary_last_name,:primary_email,:primary_phone1,:primary_phone2,:secondary_first_name,:secondary_last_name,:secondary_email,
  :secondary_phone1,:secondary_phone2,:website,:address,:city,:state,:zipcode,:notes, :primary_phone1_tag,:primary_phone2_tag, :secondary_phone1_tag, :secondary_phone2_tag

  scope :search, lambda{|query| where("company ILIKE ? OR vendor_type ILIKE ? OR trade ILIKE ? OR primary_first_name ILIKE ? OR primary_last_name ILIKE ? OR secondary_first_name ILIKE ? OR
     secondary_last_name ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")} 
     
  def full_name
     "#{primary_first_name} #{primary_last_name}"
  end
  
  def self.to_csv(vendors, options = {})
    CSV.generate(options = {}) do |csv|
      csv << HEADERS
      vendors.each do |vendor|
        csv << [vendor.vendor_type, vendor.trade, vendor.company, vendor.primary_first_name, vendor.primary_last_name, vendor.primary_email,
          vendor.primary_phone1, vendor.primary_phone1_tag, vendor.primary_phone2, vendor.primary_phone2_tag, vendor.secondary_first_name, vendor.secondary_last_name, vendor.secondary_email,
          vendor.secondary_phone1, vendor.secondary_phone1_tag, vendor.secondary_phone2, vendor.secondary_phone2_tag, vendor.website, vendor.address, vendor.city, vendor.state, vendor.zipcode,
          vendor.notes]
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
      vendor = find_by_id(row["id"]) || new
      vendor.attributes = row.to_hash.slice(*accessible_attributes)
      vendor.builder_id = builder.id
      unless vendor.save
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
