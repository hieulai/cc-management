class AddChangeOrdersCategoryIdAndRemoveCategoriesTemplateIdFromBids < ActiveRecord::Migration
  def up
    add_column :bids, :category_id, :integer
    add_index :bids, :category_id

    # Migrate categories_template_id to category_id
    Bid.all.each do |bid|
      categories_template = CategoriesTemplate.find(bid.categories_template_id)
      bid.update_attributes(:category_id => categories_template.category_id, :categories_template_id => nil)
    end

    remove_index :bids, :categories_template_id
    remove_column :bids, :categories_template_id
  end

  def down
    add_column :bids, :categories_template_id , :integer
    add_index  :bids, :categories_template_id

    remove_index :bids, :category_id
    remove_column :bids, :category_id
  end
end
