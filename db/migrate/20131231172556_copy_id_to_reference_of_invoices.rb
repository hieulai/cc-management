class CopyIdToReferenceOfInvoices < ActiveRecord::Migration
  def up
    Invoice.where('reference is null').each do |i|
      i.update_column(:reference, i.id)
    end
  end

  def down
  end
end
