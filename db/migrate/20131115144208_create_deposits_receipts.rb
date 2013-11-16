class CreateDepositsReceipts < ActiveRecord::Migration
  def change
    create_table :deposits_receipts do |t|
      t.references :deposit
      t.references :receipt
      t.decimal :amount, :scale => 2, :precision => 10

      t.timestamps
    end
    add_index :deposits_receipts, :deposit_id
    add_index :deposits_receipts, :receipt_id
  end

end
