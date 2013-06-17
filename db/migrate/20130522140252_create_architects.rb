class CreateArchitects < ActiveRecord::Migration
  def change
    create_table :architects do |t|
      t.string "company"
      t.string "first_name"
      t.string "last_name"
      t.string "email"
      t.integer "primary_phone"
      t.integer "secondary_phone"
      t.string "website"
      t.string "address"
      t.string "city"
      t.string "state"
      t.integer "zipcode"
      t.text "notes"
      t.timestamps
    end
  end
end
