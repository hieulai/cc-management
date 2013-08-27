class RenameMarginToMarkupOfItems < ActiveRecord::Migration
  def up
    rename_column :items, :margin, :markup
  end

  def down
    rename_column :items, :markup, :margin
  end
end