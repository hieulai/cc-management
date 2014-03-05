class Payment < ActiveRecord::Base
  acts_as_paranoid
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :account
  belongs_to :vendor
  has_many :payments_bills, :dependent => :destroy

  has_many :bills, :through => :payments_bills


  default_scope order("date DESC")
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }

  accepts_nested_attributes_for :payments_bills, :allow_destroy => true
  
  attr_accessible :date, :memo, :method, :reference, :reconciled , :builder_id, :account_id, :vendor_id, :payments_bills_attributes

  validates_presence_of :vendor, :account, :builder, :method, :date

  after_update :update_account_balance, :if => :account_id_changed?

  METHODS = ["Check", "Debit Card", "Wire", "EFT"]

  mapping do

    indexes :vendor_name, type: 'string', :as => 'vendor_name'
    indexes :account_name, type: 'string', :as => 'account_name'
  end

  def as_indexed_json(options={})
    self.as_json(methods: [:account_name, :vendor_name])
  end

  def account_name
    account.try(:name)
  end

  def vendor_name
    vendor.try(:display_name)
  end

  def amount
    payments_bills.map(&:amount).compact.sum if payments_bills.any?
  end

  def display_priority
    1
  end

  private
  def update_account_balance
    old_account = Account.find(account_id_was)
    account = Account.find(account_id)
    payments_bills.each do |pb|
      old_account.update_attribute(:balance, old_account.balance.to_f + pb.amount)
      account.update_attribute(:balance, account.balance.to_f - pb.amount)
    end
  end

end
