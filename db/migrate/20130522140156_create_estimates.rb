class CreateEstimates < ActiveRecord::Migration
  def change
    create_table :estimates do |t|
      t.references :builder
      t.references :project
      t.string "template"
      t.string "progress"
      t.string "status", :default => "Current Estimate"
      t.date "deadline"
      t.integer "revenue"
      t.integer "profit"
      t.integer "margin"
      t.text "notes"
      t.timestamps
    end
    add_index :estimates, :builder_id
    add_index :estimates, :project_id
  end
end
