class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.references :builder
      t.string "name"
      t.decimal "balance", :scale => 2, :precision => 10
      t.integer "number"
      t.string "category"
      t.string "subcategory"
      t.string "prefix"
      t.timestamps
    end
    add_index :accounts, :builder_id
  end
end
