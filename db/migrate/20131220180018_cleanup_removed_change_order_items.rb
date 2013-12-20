class CleanupRemovedChangeOrderItems < ActiveRecord::Migration
  def up
    Item.where('change_orders_category_id is not null').each do |i|
      next if ChangeOrdersCategory.exists? i.change_orders_category_id
      i.destroy
    end
  end

  def down
  end
end
