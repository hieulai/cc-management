class MigrateCompanyInfoFromClientsAndContactsAndVendorsToCompanies < ActiveRecord::Migration
  def up
    Client.where('company <>\'\'').each do |cl|
      c = ClientCompany.where(company_name: cl.read_attribute(:company), city: cl.city, state: cl.state, address: cl.address).first_or_create
      c.clients << cl
    end

    Contact.where('company <>\'\'').each do |ct|
      c = ContactCompany.where(company_name: ct.read_attribute(:company), city: ct.city, state: ct.state, address: ct.address).first_or_create
      c.contacts << ct
    end

    Vendor.where('company <>\'\'').each do |v|
      c = VendorCompany.where(company_name: v.read_attribute(:company), city: v.city, state: v.state, address: v.address).first_or_create
      c.vendors << v
    end
  end

  def down
  end
end
