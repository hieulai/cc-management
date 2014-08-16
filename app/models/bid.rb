# == Schema Information
#
# Table name: bids
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  notes       :text
#  chosen      :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  vendor_id   :integer
#  due_date    :date
#  category_id :integer
#  deleted_at  :time
#  builder_id  :integer
#  estimate_id :integer
#

class Bid < ActiveRecord::Base

  acts_as_paranoid
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :project
  belongs_to :estimate
  belongs_to :vendor
  belongs_to :category
  has_many :bids_items, :dependent => :destroy

  attr_accessible :notes, :chosen, :vendor_id, :category_id, :bids_items_attributes, :estimate_id
  accepts_nested_attributes_for :bids_items, :allow_destroy => true, :reject_if => lambda { |x| x[:amount].blank? }

  scope :chosen, where(chosen: true)
  validates_presence_of :category, :estimate, :builder

  def total_amount
    bids_items.map(&:amount).compact.sum if bids_items.any?
  end

  def item_amount(item_id)
    bids_items.where(:item_id => item_id).first.try(:amount)
  end

  def items
    categories_template.try(:items)
  end

  def co_items
    if categories_template
      categories_template.co_items
    elsif category
      estimate.project.co_items(category)
    end
  end

  private
  def categories_template
    category.try(:categories_templates).try(:first)
  end
end
