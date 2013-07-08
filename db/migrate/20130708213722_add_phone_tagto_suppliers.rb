class AddPhoneTagtoSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :primary_phone_tag, :string
    add_column :suppliers, :secondary_phone_tag, :string
  end
end
