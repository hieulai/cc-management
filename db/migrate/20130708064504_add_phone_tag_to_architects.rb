class AddPhoneTagToArchitects < ActiveRecord::Migration
  def change
    add_column :architects, :primary_phone_tag, :string
    add_column :architects, :secondary_phone_tag, :string
  end
  
end
