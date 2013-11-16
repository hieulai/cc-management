class CreateReceiptsInvoices < ActiveRecord::Migration
  def change
    create_table :receipts_invoices do |t|
      t.references :receipt
      t.references :invoice
      t.decimal :amount, :scale => 2, :precision => 10

      t.timestamps
    end
    add_index :receipts_invoices, :receipt_id
    add_index :receipts_invoices, :invoice_id
  end
end
