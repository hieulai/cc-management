class CreateCategoriesTemplatesItems < ActiveRecord::Migration
  def change
    create_table :categories_templates_items, id: false do |t|
      t.integer :categories_template_id
      t.integer :item_id
    end

    add_index :categories_templates_items, :categories_template_id
    add_index :categories_templates_items, :item_id
  end
end