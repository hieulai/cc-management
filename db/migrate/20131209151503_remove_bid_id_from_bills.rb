class RemoveBidIdFromBills < ActiveRecord::Migration
  def up
    #Remove all bid generated bills and payments bills
    bills = Bill.where('bid_id is not null')
    PaymentsBill.where('bill_id in (?)', bills.pluck(:id)).destroy_all
    bills.destroy_all

    remove_index :bills, :bid_id
    remove_column :bills, :bid_id
  end

  def down
    add_column :bills, :bid_id, :integer
    add_index :bills, :bid_id
  end
end
