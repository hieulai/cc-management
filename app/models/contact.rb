class Contact < ActiveRecord::Base
  include Billable

  belongs_to :builder, :class_name => "Base::Builder"
  has_many :receipts, as: :payer

  attr_accessible :primary_first_name, :primary_last_name, :primary_email, :primary_phone1, :primary_phone2, :address, :city, :state, :zipcode, :notes,
                  :primary_phone1_tag, :primary_phone2_tag
  scope :search_by_name, lambda { |q|
    (q ? where(["primary_first_name ILIKE ? or primary_last_name ILIKE ? or concat(primary_first_name, ' ', primary_last_name) ILIKE ?", '%'+ q + '%','%'+ q + '%' ,'%'+ q + '%' ])  : {})
  }

  searchable do
    integer :builder_id
    string :full_name do
      full_name
    end
    string :primary_phone do
      primary_phone
    end
    string :email do
      email
    end
    string :project_names do
      project_names
    end
    string :contact_type do
      type
    end

    string :notes
    text :primary_first_name, :primary_last_name, :primary_email, :primary_phone1, :notes
    text :contact_type do
      type
    end
  end

  def email
    primary_email
  end

  def display_name
    full_name
  end
     
  def full_name
      "#{primary_first_name} #{primary_last_name}"
  end

  def company
    ""
  end

  def primary_phone
    primary_phone1.to_s
  end

  def type
    "Other"
  end

  def project_names
    ""
  end

  def notes
    read_attribute(:notes).to_s
  end

end
