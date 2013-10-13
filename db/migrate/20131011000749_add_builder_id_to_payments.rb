class AddBuilderIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :builder_id, :integer
    add_index :payments, :builder_id
  end
end
