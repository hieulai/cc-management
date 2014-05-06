class AddCachedTotalAmountToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :cached_total_amount, :decimal, :precision => 10, :scale => 2

    Receipt.all.each do |r|
      r.update_column(:cached_total_amount, r.amount)
    end
  end
end
