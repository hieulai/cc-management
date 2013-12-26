class Estimate < ActiveRecord::Base
  before_destroy :check_destroyable, :destroy_template

  # mount_uploader :data, DataUploader
  belongs_to :builder, :class_name => "Base::Builder", :class_name => "Base::Builder"
  belongs_to :project
  has_many :measurements , :dependent => :destroy
  has_one :template, :dependent => :destroy
  has_many :invoices, :dependent => :destroy

  scope :current, lambda { |builder_id| where("builder_id = ? AND status = ?", builder_id, "Current Estimate") }
  scope :past, lambda { |builder_id| where("builder_id = ? AND status = ?", builder_id, "Past Estimate") }

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

  private
  def check_destroyable
    if undestroyable?
      errors[:base] << "Estimate #{id} cannot be deleted once containing items which are added to an invoice"
      false
    end
  end

  def destroy_template
    template.destroy_with_associations
  end
end
