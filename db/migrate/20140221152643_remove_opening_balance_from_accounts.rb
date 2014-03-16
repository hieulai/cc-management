class RemoveOpeningBalanceFromAccounts < ActiveRecord::Migration
  def up

    Base::Builder.all.each do |b|
      next if b.accounts.empty?
      b.accounts.each do |a|
        next if a.kind_of? [Account::BANK_ACCOUNTS]
        a.update_column(:balance, a.balance({recursive: false}).to_f - a.opening_balance)
      end
    end
  end

  def down
  end
end
