class AddStatusColumntoClients < ActiveRecord::Migration
  def change
    add_column :clients, :status, :string, :default => "Lead"
  end
end
