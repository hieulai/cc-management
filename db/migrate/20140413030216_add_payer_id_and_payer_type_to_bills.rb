class AddPayerIdAndPayerTypeToBills < ActiveRecord::Migration
  def change
    add_column :bills, :payer_id, :integer
    add_column :bills, :payer_type, :string

    Bill.all.each do |b|
      b.update_column(:payer_id, b.vendor_id)
      b.update_column(:payer_type, Vendor.name)
    end
  end

end
