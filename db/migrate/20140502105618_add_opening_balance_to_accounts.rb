class AddOpeningBalanceToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :opening_balance, :decimal, :precision => 10, :scale => 2

    Account.all.each do |a|
      next unless a.kind_of? [Account::BANK_ACCOUNTS]
      a.update_column(:opening_balance, a.old_opening_balance)
    end
  end
end
