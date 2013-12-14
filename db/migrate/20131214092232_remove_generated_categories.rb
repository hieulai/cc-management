class RemoveGeneratedCategories < ActiveRecord::Migration
  def up
    CategoriesTemplate.where(:purchased => true).each do |ct|
      dup_c = ct.category
      category = Category.where(:name => dup_c.name).first
      ct.category = category
      ct.save
    end
  end

  def down
  end
end
