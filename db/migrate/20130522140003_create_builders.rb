class CreateBuilders < ActiveRecord::Migration
  def change
    create_table :builders do |t|
      t.string "company_name"
      t.integer "year_founded"
      t.string "office_phone"
      t.string "website"
      t.string "address"
      t.string "city"
      t.string "state"
      t.string "zipcode"
      t.string "tax_id"
      t.timestamps
    end
  end
end
