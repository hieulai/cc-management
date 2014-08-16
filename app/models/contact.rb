# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  builder_id :integer
#  website    :string(255)
#  address    :string(255)
#  city       :string(255)
#  state      :string(255)
#  zipcode    :string(255)
#  notes      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company    :string(255)
#  deleted_at :time
#  company_id :integer
#

class Contact < ActiveRecord::Base
  include Profileable
  include Personable
  include Billable

  searchable do
    integer :builder_id
    string :type do
      type
    end
    text :type do
      type
    end
  end

  def type
    "Other"
  end

  def notes
    read_attribute(:notes).to_s
  end

end
