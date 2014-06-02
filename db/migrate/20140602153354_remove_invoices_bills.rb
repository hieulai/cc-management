class RemoveInvoicesBills < ActiveRecord::Migration
  def up
    drop_table :accounts_invoices_bills
    drop_table :invoices_bills

  end

  def down
  end
end
