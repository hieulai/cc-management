class AddRetainedEarningsAndDepositsHeldAndOperatingExpensesAccounts < ActiveRecord::Migration
  def up
    Base::Builder.all.each do |b|
      next if b.accounts.empty?
      eq_account = b.accounts.top.where(name: Account::EQUITY).first
      ex_account = b.accounts.top.where(name: Account::EXPENSES).first
      a_account = b.accounts.top.where(name: Account::ASSETS).first

      b.accounts.create(name: Account::RETAINED_EARNINGS, parent_id: eq_account.id)
      b.accounts.create(name: Account::DEPOSITS_HELD, parent_id: a_account.id)
      b.accounts.create(name: Account::OPERATING_EXPENSES, parent_id: ex_account.id)
    end

  end

  def down
  end
end
