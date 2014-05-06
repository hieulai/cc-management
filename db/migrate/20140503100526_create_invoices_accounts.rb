class CreateInvoicesAccounts < ActiveRecord::Migration
  def change
    create_table :invoices_accounts do |t|
      t.belongs_to :account
      t.belongs_to :invoice
      t.date :date
      t.decimal :amount, :scale => 2, :precision => 10

      t.timestamps
    end

    add_index :invoices_accounts, :account_id
    add_index :invoices_accounts, :invoice_id
  end
end
