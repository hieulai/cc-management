class BillsCategoriesTemplate < ActiveRecord::Base
  belongs_to :bill
  belongs_to :categories_template
  has_many :bills_items, :dependent => :destroy
  has_many :items, :dependent => :destroy
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy

  accepts_nested_attributes_for :bills_items, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :items, :reject_if => :all_blank, :allow_destroy => true
  attr_accessible :bill_id, :categories_template_id, :category_id, :bills_items_attributes, :items_attributes
  attr_accessor :category_id

  after_save :update_transactions
  after_destroy :destroy_purchased_categories_template

  def amount
    bills_items.reject(&:marked_for_destruction?).map(&:actual_cost).compact.sum +
        items.reject(&:marked_for_destruction?).map(&:actual_cost).compact.sum
  end

  def purchasable_item(item_id)
    bills_items.where(:item_id => item_id).first
  end

  def update_transactions
    cogs_account_id = CategoriesTemplate.find(categories_template_id).cogs_account.id
    accounting_transactions.where(account_id: cogs_account_id).first_or_create.update_attributes({account_id: cogs_account_id, date: bill.date, amount: amount.to_f})
  end

  def destroy_purchased_categories_template
    categories_template.destroy if categories_template.purchased && categories_template.bills_categories_templates.empty?
  end
end