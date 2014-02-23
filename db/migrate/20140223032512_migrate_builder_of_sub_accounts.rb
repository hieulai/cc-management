class MigrateBuilderOfSubAccounts < ActiveRecord::Migration
  def up
    Account.unscoped.joins(:parent).order(:id).each do |a|
      a.update_column(:builder_id, a.parent.try(:builder_id))
    end
  end

  def down
  end
end
