# == Schema Information
#
# Table name: transfers
#
#  id              :integer          not null, primary key
#  from_account_id :integer
#  to_account_id   :integer
#  date            :date
#  amount          :decimal(10, 2)
#  reference       :string(255)
#  memo            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  kind            :string(255)
#  deleted_at      :time
#

class Transfer < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :from_account, :foreign_key => "from_account_id", :class_name => Account.name
  belongs_to :to_account, :foreign_key => "to_account_id", :class_name => Account.name
  has_many :accounting_transactions, as: :transactionable, dependent: :destroy
  attr_accessible :date, :amount, :reference, :memo, :kind, :from_account_id, :to_account_id

  before_save :check_top_accounts, :if => Proc.new { |i| i.from_account.top? || i.to_account.top? }
  after_initialize :default_values
  after_save :update_transactions

  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }

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

  def account_amount
    absolute_amount(amount, from_account, to_account, true)
  end

  def absolute_amount(a, f_account, t_account, is_from_account)
    CASES.each do |c|
      if (f_account.kind_of?(c[0][:name]) && t_account.kind_of?(c[1][:name]))
        return a * (is_from_account ? c[0][:value] : c[1][:value])
      end
    end
    return a * (is_from_account ? -1 : 1)
  end

  private
  def update_transactions
    from_account = Account.find(self.from_account_id)
    to_account = Account.find(self.to_account_id)
    accounting_transactions.where(account_id: from_account_id_was || from_account_id).first_or_create.update_attributes({account_id: from_account_id, date: date, amount: absolute_amount(amount, from_account, to_account, true)})
    accounting_transactions.where(account_id: to_account_id_was|| to_account_id ).first_or_create.update_attributes({account_id: to_account_id, date: date, amount: absolute_amount(amount, from_account, to_account, false)})
  end

  def check_top_accounts
    errors[:base] << "GL Transfers can not be made from/to top-level GL Accounts (Assets, Cost of Goods Sold, Equity, Expenses, Liabilities, Revenue). Create sub-accounts under the main GL Accounts and make transfers between the sub-accounts instead."
    false
  end

  def default_values
    self.kind ||= "Bank Transfer"
  end
end
