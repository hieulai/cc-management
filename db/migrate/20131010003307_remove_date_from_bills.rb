class RemoveDateFromBills < ActiveRecord::Migration
  def up
    remove_column :bills, :date
  end

  def down
    add_column :bills, :date, :date
  end
end
