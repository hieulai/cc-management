class AddDeviseToUsers < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_password, :string, :null => false, :default => ""
    rename_column :users, :hashed_password, :legacy_hashed_password
    rename_column :users, :salt, :legacy_salt
  end
end
