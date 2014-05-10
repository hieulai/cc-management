class AddKindToReceipts < ActiveRecord::Migration
  def change
    rename_column :receipts, :uninvoiced , :is_uninvoiced
    add_column :receipts, :kind, :string

    Receipt.all.each do |r|
      r.update_column(:kind, r.is_uninvoiced ? "uninvoiced" : "invoiced")
    end

  end
end
