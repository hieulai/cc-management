class ClientCompany < Company
  has_many :clients, :foreign_key => "company_id", :dependent => :destroy
end
