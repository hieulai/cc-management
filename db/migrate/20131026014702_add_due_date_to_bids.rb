class AddDueDateToBids < ActiveRecord::Migration
  def change
    add_column :bids, :due_date, :date
  end
end
