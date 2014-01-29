class AddJobCostedToBills < ActiveRecord::Migration
  def change
    add_column :bills, :job_costed, :boolean, :default => true
  end
end
