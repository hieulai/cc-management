class CreateReceiptsItems < ActiveRecord::Migration
  def change
    create_table :receipts_items do |t|
      t.references :receipt
      t.references :account
      t.string :name
      t.string :description
      t.decimal :amount, :precision => 10, :scale => 2

      t.timestamps
    end
    add_index :receipts_items, :receipt_id
    add_index :receipts_items, :account_id
  end
end
