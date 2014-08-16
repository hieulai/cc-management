# == Schema Information
#
# Table name: companies
#
#  id           :integer          not null, primary key
#  company_name :string(255)
#  year_founded :integer
#  office_phone :string(255)
#  website      :string(255)
#  address      :string(255)
#  city         :string(255)
#  state        :string(255)
#  zipcode      :string(255)
#  tax_id       :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  slogan       :string(255)
#  logo         :string(255)
#  type         :string(255)
#  deleted_at   :time
#

class ClientCompany < Company
  has_many :clients, :foreign_key => "company_id", :dependent => :destroy
end
