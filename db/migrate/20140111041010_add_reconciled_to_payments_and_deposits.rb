class AddReconciledToPaymentsAndDeposits < ActiveRecord::Migration
  def change
    add_column :payments, :reconciled, :boolean, :default => false
    add_column :deposits, :reconciled, :boolean, :default => false
  end
end
