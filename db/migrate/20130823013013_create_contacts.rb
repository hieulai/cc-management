class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :builder
      t.string "primary_first_name"
      t.string "primary_last_name"
      t.string "primary_email"
      t.string "primary_phone1"
      t.string "primary_phone2"
      t.string "primary_phone1_tag"
      t.string "primary_phone2_tag"
      t.string "website"
      t.string "address"
      t.string "city"
      t.string "state"
      t.string "zipcode"
      t.text "notes"
      t.timestamps
    end
    add_index :contacts, :builder_id
  end
end
