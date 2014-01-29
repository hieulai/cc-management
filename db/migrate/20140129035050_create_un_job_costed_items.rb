class CreateUnJobCostedItems < ActiveRecord::Migration
  def change
    create_table :un_job_costed_items do |t|
      t.string :name
      t.string :description
      t.decimal :amount, :precision => 10, :scale => 2
      t.integer :bill_id
      t.integer :account_id

      t.timestamps
    end
    add_index :un_job_costed_items, :bill_id
    add_index :un_job_costed_items, :account_id
  end
end
