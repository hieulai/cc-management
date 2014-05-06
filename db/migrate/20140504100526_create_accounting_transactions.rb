class CreateAccountingTransactions < ActiveRecord::Migration
  def change
    create_table :accounting_transactions do |t|
      t.string :name
      t.integer :transactionable_id
      t.string :transactionable_type
      t.date :date
      t.decimal :amount, :scale => 2, :precision => 10
      t.boolean :reconciled, :default => false
      t.integer :account_id
      t.integer :display_priority, :default => 1

      t.timestamps
    end
    add_index :accounting_transactions, :account_id

  end
end
