class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.references :builder
      t.references :project
      t.references :vendor
      t.references :purchase_order
      t.references :categories_template
      t.date :date
      t.date :due_date
      t.boolean :paid
      t.text :notes
      t.text :amount
      t.decimal :sales_tax_rate, :scale => 4, :precision => 10
      t.decimal :shipping, :scale => 2, :precision => 10

      t.timestamps
    end
    add_index :bills, :builder_id
    add_index :bills, :project_id
    add_index :bills, :vendor_id
    add_index :bills, :categories_template_id
    add_index :bills, :purchase_order_id
  end
end
