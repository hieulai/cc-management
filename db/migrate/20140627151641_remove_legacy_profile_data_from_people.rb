class RemoveLegacyProfileDataFromPeople < ActiveRecord::Migration
  def change
    remove_column :clients, :first_name
    remove_column :clients, :last_name
    remove_column :clients, :email
    remove_column :clients, :primary_phone
    remove_column :clients, :secondary_phone
    remove_column :clients, :primary_phone_tag
    remove_column :clients, :secondary_phone_tag

    remove_column :vendors, :primary_first_name
    remove_column :vendors, :primary_last_name
    remove_column :vendors, :email
    remove_column :vendors, :primary_phone1
    remove_column :vendors, :primary_phone2
    remove_column :vendors, :secondary_first_name
    remove_column :vendors, :secondary_last_name
    remove_column :vendors, :secondary_email
    remove_column :vendors, :secondary_phone1
    remove_column :vendors, :secondary_phone2
    remove_column :vendors, :primary_phone1_tag
    remove_column :vendors, :primary_phone2_tag
    remove_column :vendors, :secondary_phone1_tag
    remove_column :vendors, :secondary_phone2_tag

    remove_column :contacts, :primary_first_name
    remove_column :contacts, :primary_last_name
    remove_column :contacts, :email
    remove_column :contacts, :primary_phone1
    remove_column :contacts, :primary_phone2
    remove_column :contacts, :primary_phone1_tag
    remove_column :contacts, :primary_phone2_tag
  end
end
