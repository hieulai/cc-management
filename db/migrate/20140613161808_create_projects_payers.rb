class CreateProjectsPayers < ActiveRecord::Migration
  def change
    create_table :projects_payers do |t|
      t.belongs_to :project
      t.integer  :payer_id
      t.string   :payer_type

      t.timestamps
    end

    add_index :projects_payers, :project_id
    add_index :projects_payers, :payer_id
  end
end
