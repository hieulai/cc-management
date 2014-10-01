class AddJobCostedAndEstimateIdToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :job_costed, :boolean
    add_column :receipts, :estimate_id, :integer

    add_index :receipts, :estimate_id
  end
end
