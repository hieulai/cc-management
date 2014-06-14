class RenameBuildersToCompanies < ActiveRecord::Migration
  def up
    rename_table :builders, :companies
  end

  def down
    rename_table :companies, :builders
  end
end
