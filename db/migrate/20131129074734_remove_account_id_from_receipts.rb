class RemoveAccountIdFromReceipts < ActiveRecord::Migration
  def up
    remove_column :receipts, :account_id
  end

  def down
    add_column :receipts, :account_id, :integer
  end
end
