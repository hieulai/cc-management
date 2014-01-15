class AddBillMemoToItems < ActiveRecord::Migration
  def change
    add_column :items, :bill_memo, :text
  end
end
