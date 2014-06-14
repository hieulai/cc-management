class MigrateBuilderToCompanies < ActiveRecord::Migration
  def up
    Company.all.each do |c|
      c.update_column(:type, Base::Builder.name)
    end
  end

  def down
  end
end
