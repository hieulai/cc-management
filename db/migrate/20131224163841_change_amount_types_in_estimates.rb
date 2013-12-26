class ChangeAmountTypesInEstimates < ActiveRecord::Migration
  def up
    change_column :estimates, :revenue, :decimal, :precision => 10, :scale => 2
    change_column :estimates, :profit, :decimal, :precision => 10, :scale => 2
    change_column :estimates, :margin, :decimal, :precision => 10, :scale => 2
  end

  def down
    change_column :estimates, :revenue, :integer
    change_column :estimates, :profit, :integer
    change_column :estimates, :margin, :integer
  end
end
