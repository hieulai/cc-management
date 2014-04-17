class AddPayerIdAndPayerTypeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payer_id, :integer
    add_column :payments, :payer_type, :string

    Payment.all.each do |p|
      p.update_column(:payer_id, p.vendor_id)
      p.update_column(:payer_type, Vendor.name)
    end
  end
end
