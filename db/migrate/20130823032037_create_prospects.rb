class CreateProspects < ActiveRecord::Migration
  def change
    create_table :prospects do |t|
      t.references :builder
      t.string "company"
      t.string "first_name"
      t.string "last_name"
      t.string "email"
      t.string "primary_phone"
      t.string "primary_phone_tag"
      t.string "secondary_phone"
       t.string "secondary_phone_tag"
      t.string "address"
      t.string "city"
      t.string "state"
      t.string "zipcode"
      t.string "lead_source"
      t.date "last_contacted"
      t.text "notes"
      t.timestamps
    end
    add_index :prospects, :builder_id
  end
end
