class Account < ActiveRecord::Base
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :payments
  has_many :deposits
  
  attr_accessible :name,:balance,:number,:category,:subcategory,:prefix

  scope :has_unbilled_receipts, lambda { |builder_id| joins(:receipts).where("accounts.builder_id= ? AND (receipts.remaining_amount is NULL OR receipts.remaining_amount > 0)", builder_id).uniq.all }

  def transactions
    r = payments + deposits
    r.sort! { |x, y| y.date <=> x.date }
  end
end
