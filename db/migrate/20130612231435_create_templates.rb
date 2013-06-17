class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.references :builder
      t.references :estimate
      t.string "name"
      t.decimal "cost_total", :scale => 2
      t.decimal "margin_total", :scale => 2
      t.decimal "price_total", :scale => 2
      t.boolean "default"
      t.timestamps
    end
    add_index :templates, :estimate_id
    add_index :templates, :builder_id
  end
end
