class Template < ActiveRecord::Base
  belongs_to :builder
  belongs_to :estimate
  has_many :categories_templates
  has_many :categories, class_name: 'Category', through: :categories_templates, source: :category
  has_many :items, class_name: 'Item', through: :categories_templates, source: :item

  attr_accessible :name, :cost_total, :margin_total, :price_total, :default,
                  :categories_attributes, :categories_templates_attributes, :items_attributes

  accepts_nested_attributes_for :categories, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :categories_templates, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true

  def clone_with_associations
    dup_template = self.dup
    dup_template.categories_templates.destroy_all
    categories_templates.each do |ct|
      dup_ct = ct.dup
      dup_c = ct.category.dup
      dup_c.builder_id = nil
      dup_ct.category = dup_c
      dup_ct.items.destroy_all
      ct.items.each do |i|
        dup_i = i.dup
        dup_i.builder = nil
        dup_ct.items << dup_i
      end
      dup_template.categories_templates << dup_ct
    end
    dup_template
  end

  def destroy_with_associations
    categories_templates.each do |ct|
      ct.items.each do |i|
        i.destroy
      end
      ct.category.destroy
    end
    destroy
  end
end
