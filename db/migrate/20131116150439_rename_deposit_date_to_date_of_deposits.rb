class RenameDepositDateToDateOfDeposits < ActiveRecord::Migration
  def up
    rename_column :deposits, :deposit_date, :date
  end

  def down
    rename_column :deposits, :date, :deposit_date
  end
end
