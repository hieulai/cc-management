class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.references :builder
      t.references :account
      t.date :deposit_date
      t.text :notes

      t.timestamps
    end
  end
end
