class AddPhoneTagtoSubcontractors < ActiveRecord::Migration
  def change
    add_column :subcontractors, :primary_phone_tag, :string
    add_column :subcontractors, :secondary_phone_tag, :string
  end
end
