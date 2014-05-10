class RemoveIsInvoicedFromReceipts < ActiveRecord::Migration
  def up
    remove_column :receipts, :is_uninvoiced
  end

  def down
  end
end
