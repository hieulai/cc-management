class AddCachedTotalAmountToBills < ActiveRecord::Migration
  def change
    add_column :bills, :cached_total_amount, :decimal, :precision => 10, :scale => 2

    Bill.all.each do |b|
      b.update_column(:cached_total_amount, b.total_amount)
    end
  end
end
