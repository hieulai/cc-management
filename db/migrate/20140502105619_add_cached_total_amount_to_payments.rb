class AddCachedTotalAmountToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :cached_total_amount, :decimal, :precision => 10, :scale => 2

    Payment.all.each do |p|
      p.update_column(:cached_total_amount, p.amount)
    end
  end
end
