class AddVendoridtoPayments < ActiveRecord::Migration
  def change
    add_column :payments, :vendor_id, :integer
    add_index :payments, :vendor_id
  end
end
