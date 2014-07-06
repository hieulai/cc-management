class RemoveLeads < ActiveRecord::Migration
  def up
    drop_table :leads
  end

  def down
  end
end
