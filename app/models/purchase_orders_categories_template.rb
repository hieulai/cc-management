class PurchaseOrdersCategoriesTemplate < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :purchase_order
  belongs_to :categories_template
  has_many :items, :dependent => :destroy
  has_many :purchase_orders_items, :dependent => :destroy
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy

  accepts_nested_attributes_for :purchase_orders_items, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :items, :reject_if => :all_blank, :allow_destroy => true
  attr_accessible :purchase_order_id, :categories_template_id, :category_id, :purchase_orders_items_attributes, :items_attributes
  attr_accessor :category_id

  after_save :update_transactions
  after_destroy :destroy_purchased_categories_template

  def amount
    purchase_orders_items.reject(&:marked_for_destruction?).map(&:actual_cost).compact.sum +
        items.reject(&:marked_for_destruction?).map(&:actual_cost).compact.sum
  end

  def purchasable_item(item_id)
    purchase_orders_items.where(:item_id => item_id).first
  end

  def update_transactions
    cogs_account_id = CategoriesTemplate.find(categories_template_id).cogs_account.id
    accounting_transactions.where(account_id: cogs_account_id).first_or_create.update_attributes({account_id: cogs_account_id, date: purchase_order.date, amount: amount.to_f})
  end

  def destroy_purchased_categories_template
    categories_template.destroy if categories_template.purchased && categories_template.purchase_orders_categories_templates.empty?
  end
end
