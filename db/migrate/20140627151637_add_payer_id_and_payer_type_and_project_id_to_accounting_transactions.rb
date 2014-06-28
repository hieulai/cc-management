class AddPayerIdAndPayerTypeAndProjectIdToAccountingTransactions < ActiveRecord::Migration
  def change
    add_column :accounting_transactions, :payer_id, :integer
    add_column :accounting_transactions, :payer_type, :string

    add_column :accounting_transactions, :project_id, :integer
    add_index :accounting_transactions, :project_id

    # Trigger to add new accounting_transactions
    Bill.all.each { |b| b.update_transactions }
    Payment.all.each { |b| b.update_transactions }
    Invoice.all.each { |b| b.update_transactions }
    Receipt.all.each { |b| b.update_transactions }
  end

end
