class Bill < ActiveRecord::Base
  include Purchasable

  before_destroy :check_readonly

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :purchase_order
  belongs_to :bid
  has_many :payments_bills, :dependent => :destroy
  has_many :payments, :through => :payments_bills

  default_scope order("due_date DESC")

  attr_accessible :purchase_order_id, :remaining_amount, :create_payment
  attr_accessor :create_payment

  scope :unpaid, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :paid, where('remaining_amount = 0')

  before_save :check_readonly

  def paid?
    self.payments_bills.any?
  end

  def full_paid?
     self.remaining_amount == 0
  end

  def generated?
    self.purchase_order.present? || self.bid.present?
  end

  def source(attr)
    if self.purchase_order.present?
      purchase_order.try(attr)
    elsif self.bid.present?
      bid.try(attr)
    else
      self.try(attr)
    end
  end

  def paid_amount
    self.payments_bills.map(&:amount).compact.sum if self.payments_bills.any?
  end

  def payment_bill(payment_id)
    self.payments_bills.where(:payment_id => payment_id).first
  end

  def total_amount
    return purchase_order.total_amount if purchase_order.present?
    return bid.total_amount if bid.present?
    t=0
    amount.each do |i|
      t+= i[:actual_cost].to_f
    end
    t + items.map(&:actual_cost).compact.sum
  end

  private

  def check_readonly
    if paid?
      errors[:base] << "This bill is already paid and can not be modified."
      false
    end
  end

end
