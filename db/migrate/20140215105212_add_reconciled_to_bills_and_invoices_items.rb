class AddReconciledToBillsAndInvoicesItems < ActiveRecord::Migration
  def change
    add_column :bills, :reconciled, :boolean, :default => false
    add_column :invoices, :reconciled, :boolean, :default => false
  end
end
