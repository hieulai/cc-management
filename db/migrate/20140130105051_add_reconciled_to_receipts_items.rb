class AddReconciledToReceiptsItems < ActiveRecord::Migration
  def change
    add_column :receipts_items, :reconciled, :boolean, :default => false
  end
end
