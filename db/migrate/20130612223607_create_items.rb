class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :builder
      t.references :template
      t.references :category
      t.string "name"
      t.string "description"
      t.decimal "qty", :scale => 2, :precision => 10
      t.string "unit"
      t.decimal "cost", :scale => 2, :precision => 10
      t.decimal "margin", :scale => 2, :precision => 10
      t.boolean "default"
      t.text "notes"
      t.timestamps
    end
    add_index :items, :builder_id 
    add_index :items, :template_id
    add_index :items, :category_id
  end
end
