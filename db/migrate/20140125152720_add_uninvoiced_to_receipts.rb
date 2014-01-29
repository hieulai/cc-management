class AddUninvoicedToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :uninvoiced, :boolean, :default => false
  end
end
