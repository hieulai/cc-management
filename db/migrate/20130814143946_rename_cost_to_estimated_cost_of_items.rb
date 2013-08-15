class RenameCostToEstimatedCostOfItems < ActiveRecord::Migration
  def up
    rename_column :items, :cost, :estimated_cost
  end

  def down
    rename_column :items, :estimated_cost, :cost
  end
end
