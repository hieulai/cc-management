class Contact < ActiveRecord::Base
  include Profileable
  include Personable
  include Billable

  belongs_to :builder, :class_name => "Base::Builder"

  attr_accessible :primary_first_name, :primary_last_name, :email, :primary_phone1, :primary_phone2,
                  :primary_phone1_tag, :primary_phone2_tag

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
