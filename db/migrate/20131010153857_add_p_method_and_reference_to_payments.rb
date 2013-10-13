class AddPMethodAndReferenceToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :method, :string
    add_column :payments, :reference, :integer
  end
end
