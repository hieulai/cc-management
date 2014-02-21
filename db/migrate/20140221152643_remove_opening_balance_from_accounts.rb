class RemoveOpeningBalanceFromAccounts < ActiveRecord::Migration
  def up

    Base::Builder.all.each do |b|
      a_account = b.accounts.top.where(name: Account::ASSETS).first
      bank_account = a_account.children.where(name: Account::BANK_ACCOUNTS).first
      b.accounts.where('id != ?', bank_account.id).each do |a|
        a.update_column(:balance, a.balance({recursive: false}).to_f - a.opening_balance)
      end
    end
  end

  def down
  end
end
