class Vendor < ActiveRecord::Base
  belongs_to :builder
  has_many :bid, :dependent => :destroy
  has_many :payments
  has_many :bills
  
  attr_accessible :company,:vendor_type,:trade,:primary_first_name,:primary_last_name,:primary_email,:primary_phone1,:primary_phone2,:secondary_first_name,:secondary_last_name,:secondary_email,
  :secondary_phone1,:secondary_phone2,:website,:address,:city,:state,:zipcode,:notes, :primary_phone1_tag,:primary_phone2_tag, :secondary_phone1_tag, :secondary_phone2_tag

  scope :search, lambda{|query| where("company ILIKE ? OR vendor_type ILIKE ? OR trade ILIKE ? OR primary_first_name ILIKE ? OR primary_last_name ILIKE ? OR secondary_first_name ILIKE ? OR
     secondary_last_name ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")}

  scope :search_by_name, lambda { |q|
    (q ? where(["company ILIKE ? or primary_first_name ILIKE ? or primary_last_name ILIKE ? or concat(primary_first_name, ' ', primary_last_name) ILIKE ?", '%'+ q + '%', '%'+ q + '%','%'+ q + '%' ,'%'+ q + '%' ])  : {})
  }

  scope :has_unpaid_bills, lambda { joins(:bills).where("payment_id is null") }

  validates :vendor_type, presence: true
  validates :trade, presence: { message: "cannot be blank for Subcontractors. Consider entering something such as: Framer, Plumber, Electrician, etc."}, if: :vendor_is_subcontractor?
  validates :company, presence: { message: "and Primary First Name cannot both be blank."}, if: :name_is_blank?
  
  def vendor_is_subcontractor?
      vendor_type == "Subcontractor"
  end
  
  def name_is_blank?
      primary_first_name == ""
  end
  
  HEADERS = ["Vendor_Type", "Trade", "Company", "Primary_First_Name", "Primary_Last_Name", "Primary_Email", "Primary_Phone1","Primary_Phone1_Tag", "Primary_Phone2","Primary_Phone2_Tag",
       "Secondary_First_Name", "Secondary_Last_Name", "Secondary_Email","Secondary_Phone1", "Secondary_Phone1_Tag", "Secondary_Phone2", "Secondary_Phone2_Tag", 
       "Website", "Address", "City", "State", "Zipcode", 
                 "Notes"]

  def display_name
    company.presence || full_name
  end

  def full_name
     "#{primary_first_name} #{primary_last_name}"
  end
  
  def self.to_csv
    CSV.generate do |csv|
      csv << HEADERS
      all.each do |vendor|
        csv << vendor.attributes.values_at(*HEADERS)
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
