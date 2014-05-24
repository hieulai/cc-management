class CreateBillsCategoriesTemplates < ActiveRecord::Migration
  def change
    create_table :bills_categories_templates do |t|
      t.references :bill
      t.references :categories_template
      t.timestamps
    end

    add_index :bills_categories_templates, :bill_id
    add_index :bills_categories_templates, :categories_template_id
  end
end
