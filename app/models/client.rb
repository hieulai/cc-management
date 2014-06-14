class Client < ActiveRecord::Base
  include Profileable
  include Billable

  belongs_to :builder, :class_name => "Base::Builder"
  has_many :projects, dependent: :destroy
  has_many :invoices, :through => :projects

  attr_accessible :first_name, :last_name, :email, :primary_phone, :secondary_phone,
                  :status, :last_contacted, :lead_source, :primary_phone_tag, :secondary_phone_tag

  scope :active, where(status: "Active")
  scope :has_unbilled_invoices, joins(:invoices).where("invoices.remaining_amount is NULL OR invoices.remaining_amount > 0")
  scope :has_unbilled_receipts, joins(:receipts).where("receipts.remaining_amount is NULL OR receipts.remaining_amount > 0")

  searchable do
    integer :builder_id
    string :status
    string :type do
      type
    end
    string :lead_source
    text :lead_source
    text :type do
      type
    end
  end

  def type
    "Client"
  end

  def notes
    read_attribute(:notes).to_s
  end
end
