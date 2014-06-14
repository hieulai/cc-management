class AddServiceProdivedToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :service_provided, :string
  end
end
