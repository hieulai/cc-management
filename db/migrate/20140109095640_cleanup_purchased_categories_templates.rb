class CleanupPurchasedCategoriesTemplates < ActiveRecord::Migration
  def up

    #Cleanup cloned category for purchased categories templates
    CategoriesTemplate.where(:purchased => true).each do |ct|
      if ct.category.builder
        category = Category.where('builder_id = ? and name = ? and id < ?', ct.category.builder_id, ct.category.name, ct.category.id).first
        if category
          ct.category.delete
          ct.update_attribute(:category_id, category.id)
        end
      end
    end
  end

  def down
  end
end
