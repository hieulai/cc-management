class Transfer < ActiveRecord::Base
  belongs_to :from_account, :foreign_key => "from_account_id", :class_name => Account.name
  belongs_to :to_account, :foreign_key => "to_account_id", :class_name => Account.name
  attr_accessible :date, :amount, :reference, :memo, :reconciled, :kind, :from_account_id, :to_account_id, :account_amount
  attr_accessor :account_amount

  before_save :check_top_accounts, :if => Proc.new { |i| Account::TOP.include?(i.from_account.name) || Account::TOP.include?(i.to_account.name) }
  before_save  :rollback_amount, :transfer_amount
  after_destroy :rollback_amount
  after_initialize :default_values

  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }

  validates_presence_of :from_account, :to_account, :date, :amount

  BANK_TRANSFERS = [Account::BANK_ACCOUNTS]

  def display_priority
    1
  end

  def account_amount
    instance_variable_get(:@account_amount) || amount
  end

  private
  def transfer_amount
    from_account_new = Account.find(self.from_account_id)
    to_account_new = Account.find(self.to_account_id)
    from_account_new.update_attribute(:balance, from_account_new.balance({recursive: false}).to_f - self.amount.to_f)
    to_account_new.update_attribute(:balance, to_account_new.balance({recursive: false}).to_f + self.amount.to_f)
  end

  def rollback_amount
    if from_account_id_was && to_account_id_was
      from_account_was = Account.find(self.from_account_id_was)
      to_account_was = Account.find(self.to_account_id_was)
      from_account_was.update_attribute(:balance, from_account_was.balance({recursive: false}).to_f + self.amount_was.to_f)
      to_account_was.update_attribute(:balance, to_account_was.balance({recursive: false}).to_f - self.amount_was.to_f)
    end
  end

  def check_top_accounts
    errors[:base] << "GL Transfers can not be made from/to top-level GL Accounts (Assets, Cost of Goods Sold, Equity, Expenses, Liabilities, Revenue). Create sub-accounts under the main GL Accounts and make transfers between the sub-accounts instead."
    false
  end

  def default_values
    self.kind ||= "Bank Transfer"
  end
end
