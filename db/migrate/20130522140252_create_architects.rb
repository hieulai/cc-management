class CreateArchitects < ActiveRecord::Migration
  def change
    create_table :architects do |t|
      t.references :builder
      t.string "company"
      t.string "first_name"
      t.string "last_name"
      t.string "email"
      t.string "primary_phone"
      t.string "secondary_phone"
      t.string "website"
      t.string "address"
      t.string "city"
      t.string "state"
      t.string "zipcode"
      t.text "notes"
      t.timestamps
    end
    add_index :architects, :builder_id
  end
end
