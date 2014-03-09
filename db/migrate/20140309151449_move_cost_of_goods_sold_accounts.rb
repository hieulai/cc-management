class MoveCostOfGoodsSoldAccounts < ActiveRecord::Migration
  def up
    Base::Builder.all.each do |b|
      next if b.accounts.empty?
      r_account = b.accounts.top.where(name: Account::EXPENSES).first
      cogs_account = b.accounts.top.where(name: Account::COST_OF_GOODS_SOLD).first
      cogs_account.update_column(:parent_id, r_account.id) if r_account && cogs_account
    end
  end

  def down
  end
end
