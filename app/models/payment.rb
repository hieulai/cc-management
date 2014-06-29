class Payment < ActiveRecord::Base
  acts_as_paranoid
  include Cacheable

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :account
  belongs_to :vendor
  belongs_to :payer, polymorphic: true, touch: true
  has_many :payments_bills, :dependent => :destroy
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy
  has_many :bills, :through => :payments_bills

  default_scope order("date DESC")
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }

  accepts_nested_attributes_for :payments_bills, :allow_destroy => true

  attr_accessible :date, :memo, :method, :reference, :builder_id, :account_id, :vendor_id,
                  :payments_bills_attributes, :payer_id, :payer_type, :cached_total_amount
  validates_presence_of :payer_id, :payer_type, :account, :builder, :method, :date

  after_save :update_transactions

  METHODS = ["Check", "Debit Card", "Wire", "EFT"]

  searchable do
    integer :method
    integer :builder_id
    date :date
    integer :reference
    string :payer_name do
      payer_name
    end
    string :method
    string :account_name do
      account_name
    end
    float :amount do
      amount
    end
    string :memo

    text :reference, :method, :memo
    text :date_t do |p|
      p.date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :amount_t do
      sprintf('%.2f', amount.to_f)
    end
    text :payer_name do
      payer_name
    end
    text :account_name do
      account_name
    end
  end

  def account_name
    account.try(:name)
  end

  def payer_name
    payer.try(:display_name)
  end

  def amount(project_id=nil)
    collection = project_id ? payments_bills.project(project_id) : payments_bills
    collection.map(&:amount).compact.sum if collection.any?
  end

  def total_amount
    amount
  end


  def update_transactions
    accounting_transactions.where(account_id: builder.accounts_payable_account.id).first_or_create.update_attributes({date: date, amount: amount.to_f * -1})
    accounting_transactions.where(account_id: account_id_was || account_id).first_or_create.update_attributes({account_id: account_id, date: date, amount: amount.to_f * -1})
    accounting_transactions.where('payer_id is NOT NULL and payer_type is NOT NULL').destroy_all
    if payments_bills.no_project.any?
      accounting_transactions.create({payer_id: payer_id, payer_type: payer_type, date: date, amount: payments_bills.no_project.sum(:amount)})
    end
    project_ids = bills.map(&:project_id).compact.uniq
    project_ids.each do |project_id|
      accounting_transactions.create({payer_id: payer_id, payer_type: payer_type, project_id: project_id, date: date, amount: amount(project_id).to_f * -1})
    end
  end
end
