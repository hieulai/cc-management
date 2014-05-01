class Estimate < ActiveRecord::Base
  before_destroy :check_destroyable

  # mount_uploader :data, DataUploader
  belongs_to :builder, :class_name => "Base::Builder", :class_name => "Base::Builder"
  belongs_to :project
  has_many :measurements , :dependent => :destroy
  has_one :template, :dependent => :destroy
  has_many :invoices, :dependent => :destroy

  scope :current, where(status: "Current Estimate")
  scope :past, where(status: "Past Estimate")

  accepts_nested_attributes_for :measurements

  attr_accessible :progress, :status, :data,
  :deadline, :revenue, :profit, :margin, :notes, :project_id, :measurements_attributes, :builder_id, :kind

  validates_presence_of :project, :builder

  def undestroyable?
    template.undestroyable?
  end

  def kind
    read_attribute(:kind) || "Guaranteed Bid"
  end

  def cost_plus_bid?
    kind == "Cost Plus Bid"
  end

  def destroy_with_associations
    return false if check_destroyable == false
    template.destroy_with_associations
    invoices.each do |i|
      i.destroy_with_associations
    end
    delete
  end

  private
  def check_destroyable
    if undestroyable?
      errors[:base] << "Estimate #{id} cannot be deleted once containing items which are added to an invoice"
      false
    end
  end
end
