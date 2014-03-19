class AddReconciledToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :reconciled, :boolean, :default => false
  end
end
