class CreateBidsItems < ActiveRecord::Migration
  def change
    create_table :bids_items do |t|
      t.references :bid
      t.references :item
      t.decimal :amount, :precision => 10, :scale => 2
      t.timestamps
    end
  end
end
