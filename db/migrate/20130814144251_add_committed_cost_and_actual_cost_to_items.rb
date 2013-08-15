class AddCommittedCostAndActualCostToItems < ActiveRecord::Migration
  def change
    add_column :items, :committed_cost, :decimal, :scale => 2, :precision => 10
    add_column :items, :actual_cost, :decimal, :scale => 2, :precision => 10
  end
end
