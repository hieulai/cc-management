class Account < ActiveRecord::Base
  REVENUE = "Revenue"
  COST_OF_GOODS_SOLD = "Cost of Goods Sold"
  EXPENSES = "Expenses"
  ASSETS = "Assets"
  LIABILITIES = "Liabilities"
  EQUITY = "Equity"
  ACCOUNTS_PAYABLE = "Accounts Payable"
  ACCOUNTS_RECEIVABLE = "Accounts Receivable"
  BANK_ACCOUNTS = 'Bank Accounts'
  RETAINED_EARNINGS = "Retained Earnings"
  DEPOSITS_HELD = "Deposits Held"
  OPERATING_EXPENSES = "Operating Expenses"
  CLIENT_CREDIT = "Client Credit"
  TOP = [REVENUE, EXPENSES, ASSETS, LIABILITIES, EQUITY]
  DEFAULTS = TOP + [ACCOUNTS_PAYABLE, ACCOUNTS_RECEIVABLE, BANK_ACCOUNTS, COST_OF_GOODS_SOLD, RETAINED_EARNINGS, DEPOSITS_HELD, OPERATING_EXPENSES, CLIENT_CREDIT]

  acts_as_paranoid
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :parent, class_name: "Account"

  has_many :payments, :dependent => :destroy
  has_many :deposits, :dependent => :destroy
  has_many :children, class_name: "Account", foreign_key: "parent_id", :dependent => :destroy
  has_many :sent_transfers, class_name: Transfer.name, foreign_key: "from_account_id", :dependent => :destroy
  has_many :received_transfers, class_name: Transfer.name, foreign_key: "to_account_id", :dependent => :destroy
  has_many :receipts_items, :dependent => :destroy
  has_many :un_job_costed_items, :dependent => :destroy
  has_many :ct_bills, :through => :categories_templates, :source => :bills
  has_many :accounting_transactions, :dependent => :destroy
  has_one :accounting_transaction, as: :transactionable, dependent: :destroy

  has_and_belongs_to_many :categories_templates
  has_and_belongs_to_many :change_orders_categories
  has_and_belongs_to_many :invoices_items
  has_and_belongs_to_many :invoices_bills_categories_templates

  attr_accessible :name, :balance, :opening_balance, :opening_balance_updated_at, :number, :category, :subcategory, :prefix, :parent_id, :builder_id

  default_scope order("name ASC")
  scope :top, where(:parent_id => nil)
  scope :undefault, where('name not in (?)', DEFAULTS)

  before_save :check_opening_balance_changed
  before_update :check_if_default, :if => Proc.new { |i| i.name_changed? || i.parent_id_changed? }
  before_destroy :check_if_default
  after_save :update_opening_balance_transaction, :update_indexes

  validates_uniqueness_of :name, scope: [:builder_id, :parent_id]
  validate :disallow_self_reference

  def transactions
    AccountingTransaction.accounts(tree_ids, tree_ids, Account.name)
  end

  def balance(options ={})
    options ||= {}
    options[:recursive] = true if options[:recursive].nil?
    r = AccountingTransaction.accounts(tree_ids(options[:recursive]), tree_ids(options[:recursive]), Account.name)
    if options[:from_date] && options[:to_date]
      r = r.date_range(options[:from_date], options[:to_date])
    end
    if options[:offset]
      ids = r.offset(options[:offset]).pluck(:id)
      r = AccountingTransaction.where(id: ids)
    end
    r.sum(:amount)
  end

  def bank_balance
    accounting_transactions.reconciled.sum(:amount)
  end

  def book_balance
    balance.to_f
  end

  def outstanding_checks_balance
    accounting_transactions.where(transactionable_type: Payment.name).unreconciled.sum(:amount)
  end

  def has_no_category?
    categories_templates.empty? && change_orders_categories.empty?
  end


  def default_account?
    Base::Builder.method_defined?("#{self.name.parameterize.underscore}_account".to_sym) &&
        self.builder.send("#{self.name.parameterize.underscore}_account".to_sym) == self
  end

  def kind_of?(names)
    return false if new_record?
    return true if names == "*"
    (self.default_account? && names.include?(self.name)) || (parent && parent.kind_of?(names))
  end

  DEFAULTS.each do |n|
    define_method("#{n.parameterize.underscore}_account?") do
      return false if new_record?
      return self.default_account? && n == self.name
    end
  end

  def as_select2_json(filters = [], disables =[])
    {
        :id => self.id,
        :name => self.name,
        :disabled => disables.include?(self.id),
        :children => self.children.reject { |a| filters.include? a.name }.collect { |a| a.as_select2_json(filters, disables) }
    }
  end

  def tree_ids(recursive = true)
    results = [id]
    if recursive
      children.each do |c|
        results << c.tree_ids
      end
    end
    results.flatten
  end

  private
  def check_if_default
    if (self.default_account?)
      errors[:base] << "Default account is can not be destroyed or modified"
      false
    end
  end

  def disallow_self_reference
    if self.id && self.parent_id == self.id
      errors.add(:base, 'Cannot set current account as sub account of it')
    end
  end

  def check_opening_balance_changed
    if self.opening_balance_changed?
      unless self.kind_of? [BANK_ACCOUNTS]
        errors.add(:base, 'Can not update opening balance for this account')
        return false
      end

      if self.opening_balance_updated_at.nil? && self.opening_balance.to_f != 0
        errors.add(:base, 'Opening balance updated date is required')
        return false
      end
    else
      self.opening_balance_updated_at = self.opening_balance_updated_at_was
    end
  end

  def check_if_has_categories_templates
    if categories_templates.any?
      errors.add(:base, 'Cannot delete an account has categories')
      return false
    end
  end

  def update_opening_balance_transaction
    create_accounting_transaction unless accounting_transaction
    accounting_transaction.update_attributes({date: opening_balance_updated_at.try(:to_date), amount: opening_balance})
  end

  def update_indexes
    Sunspot.delay.index payments
    Sunspot.delay.index deposits
  end
end
