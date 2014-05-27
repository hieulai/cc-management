class CreateInvoicesBillsCategoriesTemplates < ActiveRecord::Migration
  def change
    create_table :invoices_bills_categories_templates do |t|
      t.references :invoice
      t.references :bills_categories_template
      t.decimal :amount, :precision => 10, :scale => 2

      t.timestamps
    end
    add_index :invoices_bills_categories_templates, :invoice_id
    add_index :invoices_bills_categories_templates, :bills_categories_template_id, :name => :index_ibs_cts_on_bills_categories_template_id
  end
end
