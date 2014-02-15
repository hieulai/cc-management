class CreateAccountsCategoriesTemplates < ActiveRecord::Migration
  def change
    create_table :accounts_categories_templates do |t|
      t.belongs_to :account
      t.belongs_to :categories_template
    end
  end
end
