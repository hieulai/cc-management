class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.date    "check_back"
      t.date    "last_contacted"
      t.string  "lead_source"
      t.integer "expected_revenue"
      t.text    "lead_notes"
      t.text    "project_notes"
      t.timestamps
    end
  end
end
