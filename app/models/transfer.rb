class Transfer < ActiveRecord::Base
  belongs_to :from_account, :foreign_key => "from_account_id", :class_name => Account.name
  belongs_to :to_account, :foreign_key => "to_account_id", :class_name => Account.name
  attr_accessible :date, :amount, :reference, :memo, :reconciled, :from_account_id, :to_account_id

  before_create :transfer_amount
  validates_presence_of :from_account, :to_account, :date, :amount

  def method
    "Transfer"
  end

  private
  def transfer_amount
    self.from_account.update_attribute(:balance, self.from_account.balance.to_f - self.amount.to_f)
    self.to_account.update_attribute(:balance, self.to_account.balance.to_f + self.amount.to_f)
  end
end
