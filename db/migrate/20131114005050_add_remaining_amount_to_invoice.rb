class AddRemainingAmountToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :remaining_amount, :decimal, :scale => 2, :precision => 10
  end
end
