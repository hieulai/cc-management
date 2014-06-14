class RemoveArchitectsAndSubcontractorsAndSuppliers < ActiveRecord::Migration
  def up
    drop_table :architects
    drop_table :subcontractors
    drop_table :suppliers
  end

  def down
  end
end
