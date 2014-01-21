class Transfer < ActiveRecord::Base
  belongs_to :from_account, :foreign_key => "from_account_id", :class_name => Account.name
  belongs_to :to_account, :foreign_key => "to_account_id", :class_name => Account.name
  attr_accessible :date, :amount, :reference, :memo, :reconciled, :from_account_id, :to_account_id

  before_save :rollback_amount, :transfer_amount
  after_destroy :rollback_amount

  validates_presence_of :from_account, :to_account, :date, :amount

  def method
    "Transfer"
  end

  private
  def transfer_amount
    from_account_new = Account.find(self.from_account_id)
    to_account_new = Account.find(self.to_account_id)
    from_account_new.update_attribute(:balance, from_account_new.balance.to_f - self.amount.to_f)
    to_account_new.update_attribute(:balance, to_account_new.balance.to_f + self.amount.to_f)
  end

  def rollback_amount
    if from_account_id_was && to_account_id_was
      from_account_was = Account.find(self.from_account_id_was)
      to_account_was = Account.find(self.to_account_id_was)
      from_account_was.update_attribute(:balance, from_account_was.balance.to_f + self.amount_was.to_f)
      to_account_was.update_attribute(:balance, to_account_was.balance.to_f - self.amount_was.to_f)
    end
  end
end
