class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.references :builder
      t.references :account
      t.references :client
      t.string :method
      t.date :received_at
      t.integer :reference
      t.text :notes

      t.timestamps
    end
  end
end
