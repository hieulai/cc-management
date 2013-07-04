class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.references :builder
      t.string "company"
      t.string "primary_first_name"
      t.string "primary_last_name"
      t.string "primary_email"
      t.string "primary_phone"
      t.string "secondary_first_name"
      t.string "secondary_last_name"
      t.string "secondary_email"
      t.string "secondary_phone"
      t.string "website"
      t.string "address"
      t.string "city"
      t.string "state"
      t.string "zipcode"
      t.text "notes"
      t.timestamps
    end
    add_index :suppliers, :builder_id
  end
end
