class AddCompanyIdToClientsAndVendorsAndContacts < ActiveRecord::Migration
  def change
    add_column :clients, :company_id, :integer
    add_column :vendors, :company_id, :integer
    add_column :contacts, :company_id, :integer

    add_index :clients, :company_id
    add_index :vendors, :company_id
    add_index :contacts, :company_id
  end
end
