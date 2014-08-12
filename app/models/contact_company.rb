class ContactCompany < Company
  has_many :contacts, :foreign_key => "company_id", :dependent => :destroy
end
