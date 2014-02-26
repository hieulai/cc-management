require 'ostruct'
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
  TOP = [REVENUE, COST_OF_GOODS_SOLD, EXPENSES, ASSETS, LIABILITIES, EQUITY]
  DEFAULTS = [REVENUE, COST_OF_GOODS_SOLD, EXPENSES, ASSETS, LIABILITIES, EQUITY, ACCOUNTS_PAYABLE, ACCOUNTS_RECEIVABLE, BANK_ACCOUNTS]

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :parent, class_name: "Account"
  has_many :payments
  has_many :deposits
  has_many :children, class_name: "Account", foreign_key: "parent_id"
  has_many :sent_transfers, class_name: Transfer.name, foreign_key: "from_account_id"
  has_many :received_transfers, class_name: Transfer.name, foreign_key: "to_account_id"
  has_many :receipts_items, :dependent => :destroy
  has_many :un_job_costed_items, :dependent => :destroy
  has_and_belongs_to_many :categories_templates
  has_and_belongs_to_many :change_orders_categories
  has_many :bills, :through => :categories_templates
  has_and_belongs_to_many :invoices_items

  attr_accessible :name, :balance, :opening_balance, :opening_balance_updated_at, :opening_balance_changed, :number, :category, :subcategory, :prefix, :parent_id, :builder_id
  attr_accessor :opening_balance_changed

  default_scope order("name ASC")
  scope :top, where(:parent_id => nil)
  scope :undefault, where('name not in (?)', DEFAULTS)

  before_save :check_opening_balance_changed
  before_update :check_if_default, :if => Proc.new { |i| i.name_changed? || i.parent_id_changed?}
  before_destroy :check_if_default

  validates_uniqueness_of :name, scope: [:builder_id, :parent_id]
  validate :disallow_self_reference

  def transactions
    r = []
    r << [OpenStruct.new(date: self.opening_balance_updated_at, id: self.id, name: self.name, amount: self.opening_balance, display_priority: 0)] if self.bank_account?
    sent_transfers.each { |t| t.amount *= -1 }
    r << payments + deposits + sent_transfers + received_transfers + receipts_items + un_job_costed_items + bills + invoices
    r << children.map { |a| a.transactions }
    r.flatten.sort_by { |x| [x.date.try(:to_date) || Date.new(0), x.display_priority] }.reverse!
  end

  def balance(options ={})
    options ||= {}
    options[:recursive] = true if options[:recursive].nil?
    b = read_attribute(:balance).to_f
    if options[:from_date] && options[:to_date]
      p_amount = payments.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      d_amount = deposits.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      st_amount = sent_transfers.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      rt_amount = received_transfers.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      ri_amount = 0
      ujci_amount = 0
      if self.kind_of? ReceiptsItem::POSITIVES
        ri_amount = receipts_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      elsif self.kind_of? ReceiptsItem::NEGATIVES
        ri_amount -= receipts_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      end
      if self.kind_of? UnJobCostedItem::POSITIVES
        ujci_amount += un_job_costed_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      elsif self.kind_of? UnJobCostedItem::NEGATIVES
        ujci_amount -= un_job_costed_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      end
      scoped_bills = options[:project_id].present? ? bills.project(options[:project_id]) : bills
      scoped_invoices_items = options[:project_id].present? ? invoices_items.project(options[:project_id]) : invoices_items
      b_amount = scoped_bills.date_range(options[:from_date], options[:to_date]).map(&:cached_total_amount).compact.sum
      ii_amount = scoped_invoices_items.date_range(options[:from_date], options[:to_date]).map(&:amount).compact.sum
      b= -p_amount + d_amount - st_amount + rt_amount + ri_amount + ujci_amount + b_amount + ii_amount
    end

    b += (children.map { |a| a.balance(options) }).compact.sum if options[:recursive]
    b
  end

  def bank_balance
    bb = balance({recursive: false}).to_f + payments.where(:reconciled => false).map(&:amount).compact.sum - deposits.where(:reconciled => false).map(&:amount).compact.sum -
        received_transfers.where(:reconciled => false).map(&:amount).compact.sum + sent_transfers.where(:reconciled => false).map(&:amount).compact.sum -
        bills.where(:reconciled => false).map(&:cached_total_amount).compact.sum - invoices_items.unrecociled.map(&:amount).compact.sum
    if self.receipts_items.any?
      if self.kind_of? ReceiptsItem::POSITIVES
        bb-= receipts_items.select {|ri| !ri.reconciled}.map(&:amount).compact.sum
      elsif self.kind_of? ReceiptsItem::NEGATIVES
        bb+= receipts_items.select {|ri| !ri.reconciled}.map(&:amount).compact.sum
      end
    end

    if self.un_job_costed_items.any?
      if self.kind_of? UnJobCostedItem::POSITIVES
        bb-= un_job_costed_items.select {|ri| !ri.reconciled}.map(&:amount).compact.sum
      elsif self.kind_of? UnJobCostedItem::NEGATIVES
        bb+= un_job_costed_items.select {|ri| !ri.reconciled}.map(&:amount).compact.sum
      end
    end

    bb.round(2)
  end

  def book_balance
    balance.to_f
  end

  def outstanding_checks_balance
    payments.where(:reconciled => false).map(&:amount).compact.sum
  end

  def opening_balance
    ob = balance({recursive: false}).to_f + payments.map(&:amount).compact.sum - deposits.map(&:amount).compact.sum - received_transfers.map(&:amount).compact.sum +
        sent_transfers.map(&:amount).compact.sum - bills.map(&:cached_total_amount).compact.sum - invoices_items.map(&:amount).compact.sum
    if self.receipts_items.any?
      if self.kind_of? ReceiptsItem::POSITIVES
        ob-= receipts_items.map(&:amount).compact.sum
      elsif self.kind_of? ReceiptsItem::NEGATIVES
        ob+= receipts_items.map(&:amount).compact.sum
      end
    end

    if self.un_job_costed_items.any?
      if self.kind_of? UnJobCostedItem::POSITIVES
        ob-= un_job_costed_items.map(&:amount).compact.sum
      elsif self.kind_of? UnJobCostedItem::NEGATIVES
        ob+= un_job_costed_items.map(&:amount).compact.sum
      end
    end
    ob.round(2)
  end

  def opening_balance=(b)
    return if b.to_f == self.opening_balance
    self.opening_balance_changed = true
    self.balance = self.balance({recursive: false}).to_f + b.to_f - self.opening_balance
  end

  def kind_of?(names)
    if names.include? self.name
      true
    elsif parent
      parent.kind_of? names
    else
      false
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

  def invoices
    r = []
    invoices_items.group_by(&:invoice_id).each do |k, v|
      i = Invoice.find(k)
      i.category_amount = v.map(&:amount).compact.sum
      r << i
    end
    r
  end

  def has_no_category?
    categories_templates.empty? && change_orders_categories.empty?
  end

  def bank_account?
    return false if new_record?
    self == self.bank_account || (parent && parent.bank_account?)
  end

  def bank_account
    asset_account = self.builder.accounts.top.where(:name => Account::ASSETS).first
    asset_account.children.where(:name => Account::BANK_ACCOUNTS).first
  end

  private
  def check_if_default
    if (DEFAULTS.include? self.name_was) &&
        (parent_id.nil? ||
            parent.name == ASSETS && [BANK_ACCOUNTS, ACCOUNTS_RECEIVABLE].include?(self.name_was) ||
            parent.name == LIABILITIES && [ACCOUNTS_PAYABLE].include?(self.name_was))
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
    if self.opening_balance_changed
      unless self.bank_account?
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
end
