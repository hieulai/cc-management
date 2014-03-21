class MigrateJobCostedBillAmounts < ActiveRecord::Migration
  def up
    Bill.where(:job_costed => true).each do |b|
      b.builder.accounts_payable_account.update_attribute(:balance, b.builder.accounts_payable_account.balance({recursive: false}).to_f + b.total_amount.to_f)
      unless b.categories_template
        puts "Nil category for bill #{b.id}"
        next
      end
      b.categories_template.revenue_account.update_attribute(:balance, b.categories_template.revenue_account.balance({recursive: false}).to_f - b.total_amount.to_f)
      b.categories_template.revenue_account.delete
    end
  end

  def down
  end
end
