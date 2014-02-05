class AddKindToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :kind, :string
  end
end
