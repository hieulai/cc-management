class Bill < ActiveRecord::Base
  include Purchasable

  belongs_to :builder
  belongs_to :purchase_order
  belongs_to :payment

  attr_accessible :purchase_order_id, :payment_id

  scope :unpaid, -> { where 'payment_id is NULL' }

  before_destroy :raise_readonly

  def readonly?
    paid
  end

  def source(attr)
    if self.purchase_order.present?
      purchase_order.try(attr)
    else
      self.try(attr)
    end
  end

  def paid
    payment_id_was.present?
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
