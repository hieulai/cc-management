class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.references :estimate
      t.string "name"
      t.string "unit"
      t.decimal "amount", :scale => 2
      t.integer "stories"
      t.boolean "CA"
      t.boolean "CNC"
      t.boolean "CR"
      t.boolean "RA"
      t.boolean "RNC"
      t.boolean "RR"
      t.timestamps
    end
    add_index :measurements, :estimate_id  
  end
end
