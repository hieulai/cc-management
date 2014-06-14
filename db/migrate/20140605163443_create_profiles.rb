class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.belongs_to :person
      t.string   :first_name
      t.string   :last_name
      t.string   :email
      t.string   :phone1
      t.string   :phone1_tag
      t.string   :phone2
      t.string   :phone2_tag

      t.integer  :profileable_id
      t.string   :profileable_type
      t.timestamps
    end
    add_index :profiles, :person_id
  end
end
