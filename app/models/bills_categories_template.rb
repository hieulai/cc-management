# == Schema Information
#
# Table name: bills_categories_templates
#
#  id                     :integer          not null, primary key
#  bill_id                :integer
#  categories_template_id :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :time
#

class BillsCategoriesTemplate < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :bill
  include Invoiceable

  belongs_to :categories_template
  has_many :bills_items, :dependent => :destroy
  has_many :items, :dependent => :destroy
  has_many :invoices_bills_categories_templates, :dependent => :destroy
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy

  accepts_nested_attributes_for :bills_items, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :items, :reject_if => :all_blank, :allow_destroy => true
  attr_accessible :bill_id, :categories_template_id, :category_id, :category_name, :bills_items_attributes, :items_attributes
  attr_accessor :category_id, :category_name

  scope :date_range, lambda { |from_date, to_date| includes(:bill).where('bills.billed_date >= ? AND bills.billed_date <= ?', from_date, to_date) }

  before_update :remove_old_transactions
  after_save :update_transactions
  after_destroy :destroy_purchased_categories_template

  def price
    amount
  end

  def amount
    bills_items.reject(&:marked_for_destruction?).map(&:actual_cost).compact.sum +
        items.reject(&:marked_for_destruction?).map(&:actual_cost).compact.sum
  end

  def purchasable_item(item_id)
    bills_items.where(:item_id => item_id).first
  end

  def update_transactions
    cogs_account_id = CategoriesTemplate.find(categories_template_id).cogs_account.id
    accounting_transactions.create(account_id: cogs_account_id, date: bill.date, amount: amount.to_f)
    accounting_transactions.create(account_id: cogs_account_id, project_id: bill.project.try(:id), date: bill.date, amount: amount.to_f)
  end

  def remove_old_transactions
    accounting_transactions.destroy_all
  end

  def destroy_purchased_categories_template
    categories_template.destroy if categories_template.present? && categories_template.purchased && categories_template.bills_categories_templates.empty?
  end
end
