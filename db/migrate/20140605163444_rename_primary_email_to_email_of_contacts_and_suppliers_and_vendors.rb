class RenamePrimaryEmailToEmailOfContactsAndSuppliersAndVendors < ActiveRecord::Migration
  def up
    rename_column :contacts, :primary_email, :email
    rename_column :vendors, :primary_email, :email
  end

  def down
  end
end
