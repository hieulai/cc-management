class CreateAccountsInvoicesBills < ActiveRecord::Migration
  def change
    create_table :accounts_invoices_bills do |t|
      t.belongs_to :account
      t.belongs_to :invoices_bill
    end
    add_index :accounts_invoices_bills, :account_id
    add_index :accounts_invoices_bills, :invoices_bill_id
  end
end
