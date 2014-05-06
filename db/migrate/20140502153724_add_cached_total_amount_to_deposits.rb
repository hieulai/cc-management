class AddCachedTotalAmountToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :cached_total_amount, :decimal, :precision => 10, :scale => 2

    Deposit.all.each do |d|
      d.update_column(:cached_total_amount, d.amount)
    end
  end
end
