class AddReferenceToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :reference, :string
  end
end
