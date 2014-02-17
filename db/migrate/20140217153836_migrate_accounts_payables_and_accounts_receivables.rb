class MigrateAccountsPayablesAndAccountsReceivables < ActiveRecord::Migration
  def up
    Base::Builder.all.each do |b|
      r_account = b.accounts.top.where(name: Account::ACCOUNTS_RECEIVABLE).first
      p_account = b.accounts.top.where(name: Account::ACCOUNTS_PAYABLE).first
      l_account = b.accounts.top.where(name: Account::LIABILITIES).first
      a_account = b.accounts.top.where(name: Account::ASSETS).first

      r_account.update_column(:parent_id, a_account.id)
      p_account.update_column(:parent_id, l_account.id)
    end
  end

  def down
  end
end
