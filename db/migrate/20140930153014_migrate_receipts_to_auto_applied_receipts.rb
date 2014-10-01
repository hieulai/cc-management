class MigrateReceiptsToAutoAppliedReceipts < ActiveRecord::Migration
  def up
    Receipt.where(:kind => "invoiced").order("received_at ASC").each do |r|
      r.update_column(:kind, "client_receipt")
      r.applied_amount = r.amount
      r.allocate_invoices
      r.remove_old_transactions
      r.update_transactions
    end
  end

  def down
  end
end
