class VendorCompany < Company
  has_many :vendors, :foreign_key => "company_id", :dependent => :destroy
end
