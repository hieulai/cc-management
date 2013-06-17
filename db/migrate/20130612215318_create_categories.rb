class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.references :builder
      t.references :template
      t.string "name"
      t.decimal "cost_total", :scale => 2
      t.decimal "margin_total", :scale => 2
      t.decimal "price_total", :scale => 2
      t.boolean "default"
      t.timestamps
    end
    add_index :categories, :template_id
    add_index :categories, :builder_id  
  end
end
