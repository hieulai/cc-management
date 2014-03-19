class MigratePaymentsBillAmounts < ActiveRecord::Migration
  def up
    PaymentsBill.all.each do |pb|
      pb.payment.builder.accounts_payable_account.update_attribute(:balance, pb.payment.builder.accounts_payable_account.balance({recursive: false}).to_f - pb.amount.to_f)
    end
  end

  def down
  end
end
