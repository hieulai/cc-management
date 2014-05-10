class MigrateClientCreditAccounts < ActiveRecord::Migration
  def up
    Base::Builder.all.each do |b|
      b.client_credit_account
    end
  end

  def down
  end
end
