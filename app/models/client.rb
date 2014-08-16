# == Schema Information
#
# Table name: clients
#
#  id             :integer          not null, primary key
#  builder_id     :integer
#  company        :string(255)
#  address        :string(255)
#  city           :string(255)
#  state          :string(255)
#  zipcode        :string(255)
#  lead_source    :string(255)
#  last_contacted :date
#  notes          :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  status         :string(255)      default("Lead")
#  website        :string(255)
#  deleted_at     :time
#  company_id     :integer
#

class Client < ActiveRecord::Base
  include Profileable
  include Personable
  include Billable

  ACTIVE = "Active"
  LEAD = "Lead"

  has_many :projects, dependent: :destroy
  has_many :invoices, :through => :projects

  attr_accessible :status, :last_contacted, :lead_source

  scope :active, where(status: ACTIVE)
  scope :has_unbilled_invoices, joins(:invoices).where("invoices.remaining_amount is NULL OR invoices.remaining_amount > 0")
  scope :has_unbilled_receipts, joins(:receipts).where("receipts.remaining_amount is NULL OR receipts.remaining_amount > 0")

  after_touch :index

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

  def undestroyable?
    super || has_projects?
  end

  def dependencies
    dependencies = super
    dependencies << "projects" if has_projects?
    dependencies
  end

  def has_projects?
    super || projects.any?
  end

  def associated_projects
    [super, projects].flatten.uniq
  end

  def children_project_names
    projects.map(&:name).join(",")
  end

  def project_names
    associated_projects.map(&:name).join(",")
  end

  def type
    "Client"
  end

  def notes
    read_attribute(:notes).to_s
  end
end
