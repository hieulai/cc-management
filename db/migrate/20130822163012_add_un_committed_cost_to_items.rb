class AddUnCommittedCostToItems < ActiveRecord::Migration
  def change
    add_column :items, :uncommitted_cost, :decimal, :scale => 2, :precision => 10
  end
end
