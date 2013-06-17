class Lead < ActiveRecord::Base
  belongs_to :builder
  has_one :client
  has_one :project
  
  attr_accessible :project_name, :company, :first_name, :last_name, :email, :primary_phone, :secondary_phone, :address, :city, 
      :state, :zipcode, :project_name, :project_type, :lead_stage, :check_back, :last_contacted, :lead_source, :expected_revenue, 
      :notes, :lead_status
  
end
