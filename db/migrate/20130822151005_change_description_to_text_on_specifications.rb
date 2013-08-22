class ChangeDescriptionToTextOnSpecifications < ActiveRecord::Migration
  def change
    remove_column :specifications, :description
    add_column :specifications, :description, :text
  end
end
