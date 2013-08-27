class AddMarginToItems < ActiveRecord::Migration
  def change
    add_column :items, :margin, :decimal, :scale => 2, :precision => 10
  end
end