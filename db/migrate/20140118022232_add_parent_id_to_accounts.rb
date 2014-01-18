class AddParentIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :parent_id, :integer

    Base::Builder.all.each do |b|
      b.create_default_accounts
      b.accounts.undefault.each do |a|
        bank_account = b.accounts.where(:name => "Bank Accounts").first
        a.update_attribute(:parent_id, bank_account.id)
      end
    end
  end
end
