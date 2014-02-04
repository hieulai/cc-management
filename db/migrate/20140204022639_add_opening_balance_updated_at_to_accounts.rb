class AddOpeningBalanceUpdatedAtToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :opening_balance_updated_at, :datetime
  end
end
