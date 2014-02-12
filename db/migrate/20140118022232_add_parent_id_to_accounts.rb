class AddParentIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :parent_id, :integer

    Base::Builder.all.each do |b|
      b.create_default_accounts
      b.accounts.undefault.each do |a|
        asset_account = b.accounts.top.where(:name => Account::ASSETS).first
        bank_account = asset_account.children.where(:name => Account::BANK_ACCOUNTS).first
        a.update_attribute(:parent_id, bank_account.id)
      end
    end
  end
end
