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

    def accounts_receivable_account
      self.send("#{Account::ASSETS.parameterize.underscore}_account".to_sym).
          children.where(:name => Account::ACCOUNTS_RECEIVABLE, builder_id: id).
          first_or_create
    end

    def deposits_held_account
      self.send("#{Account::ASSETS.parameterize.underscore}_account".to_sym).
          children.where(:name => Account::DEPOSITS_HELD, builder_id: id).
          first_or_create
    end

    def bank_accounts_account
      self.send("#{Account::ASSETS.parameterize.underscore}_account".to_sym).
          children.where(:name => Account::BANK_ACCOUNTS, builder_id: id).
          first_or_create
    end

    def accounts_payable_account
      self.send("#{Account::LIABILITIES.parameterize.underscore}_account".to_sym).
          children.where(:name => Account::ACCOUNTS_PAYABLE, builder_id: id).
          first_or_create
    end

    def retained_earnings_account
      self.send("#{Account::EQUITY.parameterize.underscore}_account".to_sym).
          children.where(:name => Account::RETAINED_EARNINGS, builder_id: id).
          first_or_create
    end

    def cost_of_goods_sold_account
      self.send("#{Account::EXPENSES.parameterize.underscore}_account".to_sym).
          children.where(:name => Account::COST_OF_GOODS_SOLD, builder_id: id).
          first_or_create
    end

    def operating_expenses_account
      self.send("#{Account::EXPENSES.parameterize.underscore}_account".to_sym).
          children.where(:name => Account::OPERATING_EXPENSES, builder_id: id).
          first_or_create
    end

    Account::TOP.each do |n|
      define_method("#{n.parameterize.underscore}_account") do
        accounts.top.where(name: n, builder_id: id).first_or_create
      end
    end

    def create_default_accounts
      Account::DEFAULTS.each do |n|
        self.send("#{n.parameterize.underscore}_account".to_sym)
      end
    end
  end

end