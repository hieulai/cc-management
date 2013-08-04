class AddSloganAndLogoToBuilders < ActiveRecord::Migration
  def change
    add_column :builders, :slogan, :string
    add_column :builders, :logo, :string
  end
end
