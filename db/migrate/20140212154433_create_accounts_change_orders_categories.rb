class CreateAccountsChangeOrdersCategories < ActiveRecord::Migration
  def change
    create_table :accounts_change_orders_categories do |t|
      t.belongs_to :account
      t.belongs_to :change_orders_category
    end
  end
end
