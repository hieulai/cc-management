class MigrateDataToProfiles < ActiveRecord::Migration
  def up
    Client.all.each do |c|
      c.profiles.create({email: c.email, first_name: c.first_name, last_name: c.last_name,
                         phone1: c.primary_phone, phone1_tag: c.primary_phone_tag,
                         phone2: c.secondary_phone, phone2_tag: c.secondary_phone_tag})
    end

    Contact.all.each do |c|
      c.profiles.create({email: c.email, first_name: c.primary_first_name, last_name: c.primary_last_name,
                         phone1: c.primary_phone1, phone1_tag: c.primary_phone1_tag,
                         phone2: c.primary_phone2, phone2_tag: c.primary_phone2_tag})

    end

    Vendor.all.each do |v|
      v.profiles.create({email: v.email, first_name: v.primary_first_name, last_name: v.primary_last_name,
                         phone1: v.primary_phone1, phone1_tag: v.primary_phone1_tag,
                         phone2: v.primary_phone2, phone2_tag: v.primary_phone2_tag})

      v.profiles.create({email: v.secondary_email, first_name: v.secondary_first_name, last_name: v.secondary_last_name,
                         phone1: v.secondary_phone1, phone1_tag: v.secondary_phone1_tag,
                         phone2: v.secondary_phone2, phone2_tag: v.secondary_phone2_tag})
    end
  end

  def down
  end
end
