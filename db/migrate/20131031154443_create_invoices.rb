class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :builder
      t.references :estimate

      t.date :sent_date
      t.integer :reference

      t.timestamps
    end
    add_index :invoices, :builder_id
    add_index :invoices, :estimate_id
  end
end
