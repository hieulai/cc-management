class Deposit < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :account
  has_many :deposits_receipts, :dependent => :destroy
  has_many :receipts, :through => :deposits_receipts

  attr_accessible :date, :notes, :reconciled, :account_id, :builder_id, :deposits_receipts_attributes, :reference
  accepts_nested_attributes_for :deposits_receipts, :allow_destroy => true

  default_scope order("date DESC")
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }

  after_update :update_account_balance, :if => :account_id_changed?

  validates_presence_of :account, :builder, :date

  mapping do
    indexes :account_name, type: 'string', :as => 'account_name'
  end

  def as_indexed_json(options={})
    self.as_json(methods: [:account_name])
  end

  def account_name
    account.try(:name)
  end

  def amount
    deposits_receipts.map(&:amount).compact.sum if deposits_receipts.any?
  end

  def display_priority
    1
  end

  private
  def update_account_balance
    old_account = Account.find(account_id_was)
    account = Account.find(account_id)
    deposits_receipts.each do |dr|
      old_account.update_column(:balance, old_account.balance.to_f - dr.amount)
      account.update_column(:balance, account.balance.to_f + dr.amount)
    end
  end
end
