class Vendor < ActiveRecord::Base
  include Profileable
  include Personable
  include Billable
  has_many :bids, :dependent => :destroy

  attr_accessible :vendor_type, :trade, :service_provided

  validates :vendor_type, presence: true
  validates :trade, presence: {message: "cannot be blank for Subcontractors. Consider entering something such as: Framer, Plumber, Electrician, etc."}, :if => Proc.new { |v| v.vendor_type == "Subcontractor" }

  after_save :update_indexes

  searchable do
    integer :builder_id
    string :type do
      vendor_type
    end
    string :trade
    text :trade
    text :type do
      vendor_type
    end
  end

  HEADERS = ["Vendor Type", "Trade", "Company", "Primary First Name", "Primary Last Name", "Email", "Primary Phone1", "Primary Phone1 Tag", "Primary Phone2", "Primary Phone2 Tag",
             "Secondary First Name", "Secondary Last Name", "Secondary Email", "Secondary Phone1", "Secondary Phone1 Tag", "Secondary Phone2", "Secondary Phone2 Tag",
             "Website", "Address", "City", "State", "Zipcode", "Notes"]

  TYPES = ["Architect", "Engineer", "Subcontractor", "Supplier"]

  def undestroyable?
    super || bids.any?
  end

  def dependencies
    dependencies = super
    dependencies << "bids" if bids.any?
    dependencies
  end

  def type
    vendor_type
  end

  def notes
    read_attribute(:notes).to_s
  end

  def self.to_csv (vendors)
    CSV.generate do |csv|
      csv << HEADERS
      vendors.each do |vendor|
        csv << [vendor.vendor_type, vendor.trade, vendor.company,
                vendor.primary_first_name, vendor.primary_last_name, vendor.primary_email, vendor.primary_phone1, vendor.primary_phone1_tag, vendor.primary_phone2, vendor.primary_phone2_tag,
                vendor.secondary_first_name, vendor.secondary_last_name, vendor.secondary_email, vendor.secondary_phone1, vendor.secondary_phone1_tag, vendor.secondary_phone2, vendor.secondary_phone2_tag,
                vendor.website, vendor.address, vendor.city, vendor.state, vendor.zipcode, vendor.notes]
      end
    end
  end

  def update_indexes
    Sunspot.delay.index purchase_orders
    Sunspot.delay.index bids
  end
  
end
