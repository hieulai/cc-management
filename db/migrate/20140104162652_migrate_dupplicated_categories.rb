class MigrateDupplicatedCategories < ActiveRecord::Migration
  def up
    CategoriesTemplate.where(:purchased => true).each do |ct|
      puts "Checking category template Id: #{ct.id}, name: #{ct.category.name}"
      categories_templates = ct.template.categories_templates
      o_ct = categories_templates.select { |ct2| ct2.purchased == nil && ct2.category.name == ct.category.name }.first
      next unless o_ct
      puts "Migrating category template Id: #{o_ct.id}, name: #{o_ct.category.name}"
      ct.bills.each do |b|
        if b.update_column(:categories_template_id, o_ct.id)
          puts "Updated bill #{b.id}"
        end
      end
      ct.purchase_orders.each do |po|
        if po.update_column(:categories_template_id, o_ct.id)
          puts "Updated purchase order #{po.id}"
        end
      end
      ct.destroy
    end
  end

  def down
  end
end
