class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string "company"
      t.string "primay_first_name"
      t.string "primary_last_name"
      t.string "primary_email"
      t.integer "primary_phone"
      t.string "secondary_first_name"
      t.string "secondary_last_name"
      t.string "secondary_email"
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
