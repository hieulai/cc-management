class CreateInvoicesItems < ActiveRecord::Migration
  def change
    create_table :invoices_items do |t|
      t.references :invoice
      t.references :item
      t.decimal :amount, :scale => 2, :precision => 10

      t.timestamps
    end
  end
end
