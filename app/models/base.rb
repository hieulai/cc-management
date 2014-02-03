module Base
  class Builder < ActiveRecord::Base
    has_one :image, as: :imageable, dependent: :destroy

    #Relations
    has_many :architects
    has_many :clients
    has_many :projects
    has_many :estimates
    has_many :users
    has_many :items
    has_many :categories
    has_many :templates
    has_many :accounts
    has_many :tasklists
    has_many :vendors
    has_many :contacts
    has_many :prospects
    has_many :receipts
    has_many :bills
    has_many :purchase_orders
    has_many :payments
    has_many :invoices
    has_many :deposits
    has_many :subcontractors
    has_many :suppliers

    attr_accessible :company_name, :year_founded, :office_phone, :website, :address, :city, :state, :zipcode, :tax_id, :logo, :slogan, :image_attributes
    accepts_nested_attributes_for :image

    after_create :create_default_accounts

    def create_default_accounts
      Account::DEFAULTS.each do |name|
        if name == "Bank Accounts"
          assets_account = self.accounts.where(:name => "Assets").first
        end
        if self.accounts.where(:name => name, :parent_id => assets_account.try(:id)).empty?
          self.accounts.create(:name => name, :parent_id => assets_account.try(:id))
        end
      end
    end

  end

end