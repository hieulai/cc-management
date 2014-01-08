class CleanupCategories < ActiveRecord::Migration
  def up
    Category.where('builder_id is not null').each do |c|
      c.categories_templates.each do |ct|
        unless ct.template
          # Clean up orphan categories templates
          ct.destroy
        else
          # Cloning category
          if ct.template.estimate
            category_dup = ct.category.dup
            category_dup.save
            ct.update_attribute(:category_id, category_dup.id)
          end
        end
      end
    end
  end

  def down
  end
end
