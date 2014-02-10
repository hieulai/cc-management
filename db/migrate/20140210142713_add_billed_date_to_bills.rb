class AddBilledDateToBills < ActiveRecord::Migration
  def change
    add_column :bills, :billed_date, :date

    Bill.all.each do |b|
      b.update_column(:billed_date, b.paid? ? b.payments.first.date : b.created_at.to_date)
    end
  end
end
