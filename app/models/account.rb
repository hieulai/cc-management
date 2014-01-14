class Account < ActiveRecord::Base
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :payments
  has_many :deposits
  
  attr_accessible :name,:balance,:number,:category,:subcategory,:prefix

  scope :has_unbilled_receipts, lambda { |builder_id| joins(:receipts).where("accounts.builder_id= ? AND (receipts.remaining_amount is NULL OR receipts.remaining_amount > 0)", builder_id).uniq.all }
  scope :raw, lambda { |builder_id| where("builder_id = ?", builder_id) }

  def transactions
    r = payments + deposits
    r.sort! { |x, y| y.date <=> x.date }
  end

  def bank_balance
    balance.to_f + payments.where(:reconciled => true).map(&:amount).compact.sum - deposits.where(:reconciled => true).map(&:amount).compact.sum
  end

  def book_balance
     balance
  end

  def outstanding_checks_balance
    payments.where(:reconciled => false).map(&:amount).compact.sum
  end
end
