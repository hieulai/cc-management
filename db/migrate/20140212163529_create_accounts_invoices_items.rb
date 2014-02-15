class CreateAccountsInvoicesItems < ActiveRecord::Migration
  def change
    create_table :accounts_invoices_items do |t|
      t.belongs_to :account
      t.belongs_to :invoices_item
    end
  end
end
