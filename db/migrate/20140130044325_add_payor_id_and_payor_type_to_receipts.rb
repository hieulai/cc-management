class AddPayorIdAndPayorTypeToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :payer_id, :integer
    add_column :receipts, :payer_type, :string
  end
end
