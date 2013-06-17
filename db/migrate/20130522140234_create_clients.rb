class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string "company"
      t.string "first_name"
      t.string "last_name"
      t.string "email"
      t.integer "primary_phone"
      t.integer "secondary_phone"
      t.string "address"
      t.string "city"
      t.string "state"
      t.integer "zipcode"
      t.string "lead_source"
      t.date "last_contacted"
      t.text "notes"
      t.timestamps
    end
  end
end
