class RemoveTemplateColumnFromEstimates < ActiveRecord::Migration
  def change
    remove_column :estimates, :template
  end
end
