class AddBillsCategoriesTemplateIdToBillsItems < ActiveRecord::Migration
  def change
    add_column :bills_items, :bills_categories_template_id, :integer
    add_index :bills_items, :bills_categories_template_id, :name => :index_bills_items_on_bills_ct_id
  end
end
