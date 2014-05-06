class AddCachedTotalAmountToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :cached_total_amount, :decimal, :precision => 10, :scale => 2

    Invoice.all.each do |i|
      i.update_column(:cached_total_amount, i.amount)
    end
  end
end
