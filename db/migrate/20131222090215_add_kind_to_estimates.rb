class AddKindToEstimates < ActiveRecord::Migration
  def change
    add_column :estimates, :kind, :string
  end
end
