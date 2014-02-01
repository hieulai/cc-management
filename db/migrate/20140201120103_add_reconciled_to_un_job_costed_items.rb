class AddReconciledToUnJobCostedItems < ActiveRecord::Migration
  def change
    add_column :un_job_costed_items, :reconciled, :boolean, :default => false
  end
end
