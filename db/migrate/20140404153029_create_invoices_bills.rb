class CreateInvoicesBills < ActiveRecord::Migration
  def change
    create_table :invoices_bills do |t|
      t.references :invoice
      t.references :bill
      t.decimal :amount, :precision => 10, :scale => 2
      t.boolean :reconciled, :default => false

      t.timestamps
    end
    add_index :invoices_bills, :invoice_id
    add_index :invoices_bills, :bill_id
  end
end
