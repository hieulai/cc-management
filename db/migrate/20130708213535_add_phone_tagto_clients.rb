class AddPhoneTagtoClients < ActiveRecord::Migration
  def change
    add_column :clients, :primary_phone_tag, :string
    add_column :clients, :secondary_phone_tag, :string
  end
end
