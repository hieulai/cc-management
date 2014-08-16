# == Schema Information
#
# Table name: templates
#
#  id           :integer          not null, primary key
#  builder_id   :integer
#  estimate_id  :integer
#  name         :string(255)
#  cost_total   :integer
#  margin_total :integer
#  price_total  :integer
#  default      :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :time
#

class Template < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :estimate
  has_many :categories_templates, :dependent => :destroy
  has_many :categories, class_name: 'Category', through: :categories_templates, source: :category
  has_many :items, class_name: 'Item', through: :categories_templates, source: :item

  attr_accessible :name, :cost_total, :margin_total, :price_total, :default,
                  :categories_attributes, :categories_templates_attributes, :items_attributes

  accepts_nested_attributes_for :categories, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :categories_templates, reject_if: :all_blank, allow_destroy: true

  scope :raw, where(estimate_id: nil)

  before_destroy :check_destroyable, :prepend => true

  validates :name, presence: true

  def clone_with_associations
    dup_template = self.dup
    dup_template.categories_templates.destroy_all
    categories_templates.each do |ct|
      dup_ct = ct.dup
      dup_c = ct.category.dup
      dup_c.builder_id = nil
      dup_c.save
      dup_ct.update_attributes(:category_id => dup_c.id)
      dup_ct.items.destroy_all
      ct.items.each do |i|
        dup_i = i.dup
        dup_i.builder = nil
        dup_ct.items << dup_i
      end
      dup_template.categories_templates << dup_ct
      dup_template.builder = nil
    end
    dup_template
  end

  def undestroyable?
    categories_templates.select { |ct| ct.undestroyable? }.any?
  end

  def check_destroyable
    if undestroyable?
      errors[:invoice] << "Template #{name} cannot be deleted once containing items which are added to an invoice"
      false
    end
  end
end
