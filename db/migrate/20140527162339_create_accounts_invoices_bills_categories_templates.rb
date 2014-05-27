class CreateAccountsInvoicesBillsCategoriesTemplates < ActiveRecord::Migration
  def change
    create_table :accounts_invoices_bills_categories_templates do |t|
      t.belongs_to :account
      t.belongs_to :invoices_bills_categories_template
    end
    add_index :accounts_invoices_bills_categories_templates, :account_id, name: :index_a_ibs_cts_on_account_id
    add_index :accounts_invoices_bills_categories_templates, :invoices_bills_categories_template_id, name: :index_a_ibs_cts_on_ibs_ct_id
  end
end
