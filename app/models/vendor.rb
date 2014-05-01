class Vendor < ActiveRecord::Base
  include Importable
  include Billable

  belongs_to :builder, :class_name => "Base::Builder"
  has_many :bid, :dependent => :destroy
  has_many :payments
  has_many :purchase_orders
  has_many :receipts, as: :payer
  
  attr_accessible :company,:vendor_type,:trade,:primary_first_name,:primary_last_name,:primary_email,:primary_phone1,:primary_phone2,:secondary_first_name,:secondary_last_name,:secondary_email,
  :secondary_phone1,:secondary_phone2,:website,:address,:city,:state,:zipcode,:notes, :primary_phone1_tag,:primary_phone2_tag, :secondary_phone1_tag, :secondary_phone2_tag

  scope :search_by_name, lambda { |q|
    (q ? where(["company ILIKE ? or primary_first_name ILIKE ? or primary_last_name ILIKE ? or concat(primary_first_name, ' ', primary_last_name) ILIKE ?", '%'+ q + '%', '%'+ q + '%','%'+ q + '%' ,'%'+ q + '%' ])  : {})
  }

  validates :vendor_type, presence: true
  validates :trade, presence: {message: "cannot be blank for Subcontractors. Consider entering something such as: Framer, Plumber, Electrician, etc."}, :if => Proc.new { |v| v.vendor_type == "Subcontractor" }
  validates :company, presence: { message: "and Primary First Name cannot both be blank."}, :if => Proc.new { |v| v.   primary_first_name == "Subcontractor" }

  after_save :update_indexes

  searchable do
    text :company, :vendor_type, :trade, :primary_first_name, :primary_last_name, :primary_email, :primary_phone1, :notes
    integer :builder_id
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

  def update_indexes
    Sunspot.delay.index bills
    Sunspot.delay.index purchase_orders
    Sunspot.delay.index payments
  end
  
end
