class Transfer < ActiveRecord::Base
  belongs_to :from_account, :foreign_key => "from_account_id", :class_name => Account.name
  belongs_to :to_account, :foreign_key => "to_account_id", :class_name => Account.name
  attr_accessible :date, :amount, :reference, :memo, :reconciled, :kind, :from_account_id, :to_account_id
  attr_accessor :related_account
  before_save :check_top_accounts, :if => Proc.new { |i| Account::TOP.include?(i.from_account.name) || Account::TOP.include?(i.to_account.name) }
  before_save  :rollback_amount, :transfer_amount
  after_destroy :rollback_amount
  after_initialize :default_values

  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }
  scope :unrecociled, where(:reconciled => false)
  validates_presence_of :from_account, :to_account, :date, :amount

  BANK_TRANSFERS = [Account::BANK_ACCOUNTS]

  CASES = [[{name: Account::ASSETS, value: -1}, {name: Account::EQUITY, value: -1}],
           [{name: Account::ASSETS, value: -1}, {name: Account::EXPENSES, value: 1}],
           [{name: Account::ASSETS, value: -1}, {name: Account::LIABILITIES, value: -1}],
           [{name: Account::ASSETS, value: -1}, {name: Account::REVENUE, value: -1}],
           [{name: Account::EQUITY, value: 1}, {name: Account::ASSETS, value: 1}],
           [{name: Account::EQUITY, value: -1}, {name: Account::EXPENSES, value: 1}],
           [{name: Account::EQUITY, value: -1}, {name: Account::LIABILITIES, value: 1}],
           [{name: Account::EQUITY, value: -1}, {name: Account::REVENUE, value: 1}],
           [{name: Account::EXPENSES, value: -1}, {name: Account::ASSETS, value: 1}],
           [{name: Account::EXPENSES, value: -1}, {name: Account::EQUITY, value: 1}],
           [{name: Account::EXPENSES, value: -1}, {name: Account::LIABILITIES, value: -1}],
           [{name: Account::EXPENSES, value: -1}, {name: Account::REVENUE, value: 1}],
           [{name: Account::LIABILITIES, value: 1}, {name: Account::ASSETS, value: 1}],
           [{name: Account::LIABILITIES, value: -1}, {name: Account::EQUITY, value: 1}],
           [{name: Account::LIABILITIES, value: 1}, {name: Account::EXPENSES, value: 1}],
           [{name: Account::LIABILITIES, value: -1}, {name: Account::REVENUE, value: 1}],
           [{name: Account::REVENUE, value: -1}, {name: Account::ASSETS, value: -1}],
           [{name: Account::REVENUE, value: -1}, {name: Account::EQUITY, value: 1}],
           [{name: Account::REVENUE, value: -1}, {name: Account::EXPENSES, value: 1}],
           [{name: Account::REVENUE, value: -1}, {name: Account::REVENUE, value: 1}]]

  def display_priority
    1
  end

  def account_amount
    absolute_amount(amount, from_account, to_account, related_account)
  end

  def absolute_amount(a, f_account, t_account, related_account)
    CASES.each do |c|
      if (f_account.kind_of?(c[0][:name]) && t_account.kind_of?(c[1][:name]))
        return a * (f_account == related_account ? c[0][:value] : c[1][:value])
      end
    end
    return a * (t_account == related_account ? 1 : -1)
  end

  private
  def transfer_amount
    from_account_new = Account.find(self.from_account_id)
    to_account_new = Account.find(self.to_account_id)
    from_account_new.update_attribute(:balance, from_account_new.balance({recursive: false}).to_f + absolute_amount(amount, from_account_new, to_account_new, from_account_new))
    to_account_new.update_attribute(:balance, to_account_new.balance({recursive: false}).to_f + absolute_amount(amount, from_account_new, to_account_new, to_account_new))
  end

  def rollback_amount
    if Account.exists?(from_account_id_was) && Account.exists?(to_account_id_was)
      from_account_was = Account.find(self.from_account_id_was)
      to_account_was = Account.find(self.to_account_id_was)
      from_account_was.update_attribute(:balance, from_account_was.balance({recursive: false}).to_f - absolute_amount(amount_was, from_account_was, to_account_was, from_account_was))
      to_account_was.update_attribute(:balance, to_account_was.balance({recursive: false}).to_f - absolute_amount(amount_was, from_account_was, to_account_was, to_account_was))
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
