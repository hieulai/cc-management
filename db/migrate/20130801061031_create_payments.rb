class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :account
      t.decimal "amount", :scale => 2, :precision => 12
      t.date "date"
      t.string "memo"
      t.timestamps
    end
    add_index :payments, :account_id
  end
    
end
