class AddCategoriesTemplateIdToBids < ActiveRecord::Migration
  def change
    add_column :bids, :categories_template_id, :integer
    add_index :bids, :categories_template_id
  end
end
