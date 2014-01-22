class Account < ActiveRecord::Base
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :payments
  has_many :deposits
  has_many :children, class_name: "Account", foreign_key: "parent_id"
  has_many :sent_transfers, class_name: Transfer.name, foreign_key: "from_account_id"
  has_many :received_transfers, class_name: Transfer.name, foreign_key: "to_account_id"

  belongs_to :parent, class_name: "Account"

  attr_accessible :name, :balance, :opening_balance , :number, :category, :subcategory, :prefix, :parent_id

  DEFAULTS = ["Revenue", "Cost of Goods Sold", "Expenses", "Assets", "Liabilities", "Equity", "Accounts Payable", "Accounts Receivable", "Bank Accounts"]

  scope :has_unbilled_receipts, lambda { |builder_id| joins(:receipts).where("accounts.builder_id= ? AND (receipts.remaining_amount is NULL OR receipts.remaining_amount > 0)", builder_id).uniq.all }
  scope :raw, lambda { |builder_id| where("builder_id = ?", builder_id) }
  scope :top, where(:parent_id => nil)
  scope :undefault, where('name not in (?)', DEFAULTS)

  before_destroy :check_if_default
  before_update :check_if_default

  validates_uniqueness_of :name, scope: [:builder_id, :parent_id ]
  validate :disallow_self_reference

  def transactions
    r = payments + deposits + sent_transfers + received_transfers
    r.sort! { |x, y| y.date <=> x.date }
  end

  def bank_balance
    balance.to_f + payments.where(:reconciled => false).map(&:amount).compact.sum - deposits.where(:reconciled => false).map(&:amount).compact.sum - received_transfers.where(:reconciled => false).map(&:amount).compact.sum + sent_transfers.where(:reconciled => false).map(&:amount).compact.sum
  end

  def book_balance
    balance.to_f
  end

  def outstanding_checks_balance
    payments.where(:reconciled => false).map(&:amount).compact.sum
  end

  def opening_balance
    ob = balance.to_f + payments.map(&:amount).compact.sum - deposits.map(&:amount).compact.sum - received_transfers.map(&:amount).compact.sum + sent_transfers.map(&:amount).compact.sum
    ob.round(2)
  end

  def opening_balance=(b)
    self.balance = self.balance.to_f + b.to_f - self.opening_balance
  end

  def as_select2_json
    {
        :id => self.id,
        :name => self.name,
        :children => self.children.collect { |a| a.as_select2_json }
    }
  end

  private
  def check_if_default
    if DEFAULTS.include? self.name
      errors[:base] << "Default account is can not be destroyed or modified"
      false
    end
  end

  def disallow_self_reference
    if self.parent_id == self.id
      errors.add(:base, 'Cannot set current account as sub account of it')
    end
  end
end
