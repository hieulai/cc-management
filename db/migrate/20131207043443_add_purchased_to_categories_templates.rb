class AddPurchasedToCategoriesTemplates < ActiveRecord::Migration
  def change
    add_column :categories_templates, :purchased, :boolean
  end
end
