class CreateCategoriesTemplates < ActiveRecord::Migration
  def change
    create_table :categories_templates, id: false do |t|
      t.integer :category_id
      t.integer :template_id
    end

    add_index :categories_templates, :category_id
    add_index :categories_templates, :template_id
  end
end