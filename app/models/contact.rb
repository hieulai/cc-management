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
