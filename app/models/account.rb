require 'ostruct'
class Account < ActiveRecord::Base
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :payments
  has_many :deposits
  has_many :children, class_name: "Account", foreign_key: "parent_id"
  has_many :sent_transfers, class_name: Transfer.name, foreign_key: "from_account_id"
  has_many :received_transfers, class_name: Transfer.name, foreign_key: "to_account_id"
  has_many :receipts_items, :dependent => :destroy
  has_many :un_job_costed_items, :dependent => :destroy

  belongs_to :parent, class_name: "Account"

  attr_accessible :name, :balance, :opening_balance, :opening_balance_updated_at, :opening_balance_changed, :number, :category, :subcategory, :prefix, :parent_id
  attr_accessor :opening_balance_changed

  DEFAULTS = ["Revenue", "Cost of Goods Sold", "Expenses", "Assets", "Liabilities", "Equity", "Accounts Payable", "Accounts Receivable", "Bank Accounts"]

  scope :top, where(:parent_id => nil)
  scope :undefault, where('name not in (?)', DEFAULTS)

  before_destroy :check_if_default
  before_update :check_if_default, :if => Proc.new { |i| i.name_changed? || i.parent_id_changed? }
  before_update :check_opening_balance_updated_at

  validates_uniqueness_of :name, scope: [:builder_id]
  validate :disallow_self_reference

  def transactions
    opening_balance_item = [OpenStruct.new(date: self.opening_balance_updated_at,
                                           kind: "Opening Balance",
                                           reference: nil,
                                           payee: "Opening Balance",
                                           memo: "Opening Balance",
                                           amount: self.opening_balance,
                                           display_priority: 0)]
    r = payments + deposits + sent_transfers + received_transfers + receipts_items + un_job_costed_items + opening_balance_item
    r.sort_by { |x| [x.date.try(:to_date) || Date.new(0), x.display_priority] }.reverse!
  end

  def bank_balance
    bb = balance.to_f + payments.where(:reconciled => false).map(&:amount).compact.sum - deposits.where(:reconciled => false).map(&:amount).compact.sum - received_transfers.where(:reconciled => false).map(&:amount).compact.sum + sent_transfers.where(:reconciled => false).map(&:amount).compact.sum
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
    ob = balance.to_f + payments.map(&:amount).compact.sum - deposits.map(&:amount).compact.sum - received_transfers.map(&:amount).compact.sum + sent_transfers.map(&:amount).compact.sum
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
    self.balance = self.balance.to_f + b.to_f - self.opening_balance
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

  def as_select2_json(filters = [])
    {
        :id => self.id,
        :name => self.name,
        :children => self.children.reject { |a| filters.include? a.name }.collect { |a| a.as_select2_json }
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
    if self.id && self.parent_id == self.id
      errors.add(:base, 'Cannot set current account as sub account of it')
    end
  end

  def check_opening_balance_updated_at
    if self.opening_balance_changed
      if self.opening_balance_updated_at.nil?
        errors.add(:base, 'Opening balance updated date is required')
        return false
      end
    else
      self.opening_balance_updated_at = self.opening_balance_updated_at_was
    end
  end
end
