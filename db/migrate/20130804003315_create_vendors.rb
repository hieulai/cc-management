class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
        t.references :builder
        t.string "company"
        t.string "vendor_type"
        t.string "trade"
        t.string "primary_first_name"
        t.string "primary_last_name"
        t.string "primary_email"
        t.string "primary_phone1"
        t.string "primary_phone2"
        t.string "primary_phone1_tag"
        t.string "primary_phone2_tag"
        t.string "secondary_first_name"
        t.string "secondary_last_name"
        t.string "secondary_email"
        t.string "secondary_phone1"
        t.string "secondary_phone2" 
        t.string "secondary_phone1_tag"
        t.string "secondary_phone2_tag"
        t.string "website"
        t.string "address"
        t.string "city"
        t.string "state"
        t.string "zipcode"
        t.text "notes"
        t.timestamps
    end
      add_index :vendors, :builder_id
  end
end
