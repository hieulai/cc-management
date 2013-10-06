class AddBillIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :bill_id, :integer
    add_index :items, :bill_id
  end
end
