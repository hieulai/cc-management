class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.references :project
      t.decimal "amount", :scale => 2, :precision => 10
      t.text "notes"
      t.boolean "chosen"
      t.timestamps
    end
    add_index :bids, :project_id
  end
end
