class CreatePaymentsBills < ActiveRecord::Migration
  def change
    create_table :payments_bills do |t|
      t.references :payment
      t.references :bill
      t.decimal :paid_amount, :scale => 2, :precision => 10

      t.timestamps
    end
    add_index :payments_bills, :payment_id
    add_index :payments_bills, :bill_id
  end
end
