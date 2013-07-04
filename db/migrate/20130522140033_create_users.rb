class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :builder
      t.string "authority"
      t.string "first_name"
      t.string "last_name"
      t.string "email"
      t.string "primary_phone"
      t.string "hashed_password"
      t.string "salt"
      t.timestamps
    end
    add_index :users, :builder_id
  end
end
