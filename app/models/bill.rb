class Bill < ActiveRecord::Base
  include Purchasable

  belongs_to :builder
  belongs_to :purchase_order
  has_many :payments_bills, :dependent => :destroy
  has_many :payments, :through => :payments_bills

  default_scope order("due_date DESC")

  attr_accessible :purchase_order_id, :remaining_amount

  scope :unpaid, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :paid, where('remaining_amount = 0')

  before_destroy :raise_readonly

  def readonly?
    paid?
  end

  def paid?
    self.payments_bills.any?
  end

  def source(attr)
    if self.purchase_order.present?
      purchase_order.try(attr)
    else
      self.try(attr)
    end
  end

  def paid_amount
    self.payments_bills.map(&:paid_amount).compact.sum if self.payments_bills.any?
  end

  def payment_bill(payment_id)
    self.payments_bills.where(:payment_id => payment_id).first
  end

  def total_amount
    return purchase_order.total_amount if purchase_order.present?
    t=0
    amount.each do |i|
      t+= i[:estimated_cost].to_f
    end
    t + items.map(&:estimated_cost).compact.sum
  end

  private

  def raise_readonly
    raise ActiveRecord::ReadOnlyRecord if self.readonly?
  end

end
