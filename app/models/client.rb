class Client < ActiveRecord::Base
  
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :projects, dependent: :destroy
  has_many :invoices, :through => :projects
  has_many :receipts, as: :payer

  attr_accessible :company, :first_name, :last_name, :email, :primary_phone, :secondary_phone,
                  :address, :city, :state, :zipcode, :status, :notes, :last_contacted, :lead_source, :primary_phone_tag, :secondary_phone_tag

  default_scope order("first_name ASC")
  scope :active, where(status: "Active")
  scope :search, lambda{|query| where("company ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR notes ILIKE ? OR lead_source ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")}

  scope :search_by_name, lambda { |q|
    (q ? where(["first_name ILIKE ? or last_name ILIKE ? or concat(first_name, ' ', last_name) ILIKE ?", '%'+ q + '%', '%'+ q + '%', '%'+ q + '%']) : {})
  }

  scope :has_unbilled_invoices, joins(:invoices).where("invoices.remaining_amount is NULL OR invoices.remaining_amount > 0").uniq.all

  scope :has_unbilled_receipts, joins(:receipts).where("receipts.remaining_amount is NULL OR receipts.remaining_amount > 0").uniq.all
      
  def full_name
     "#{first_name} #{last_name}"
  end
end
