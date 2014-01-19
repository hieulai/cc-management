class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :from_account_id
      t.integer :to_account_id

      t.date :date
      t.decimal :amount, :precision => 10, :scale => 2
      t.string :reference
      t.text :memo
      t.boolean :reconciled, :default => false

      t.timestamps
    end
  end
end
