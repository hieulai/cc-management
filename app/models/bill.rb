class Bill < ActiveRecord::Base
  include Purchasable

  belongs_to :purchase_order

  attr_accessible :paid, :purchase_order_id

  after_initialize :default_values

  def source(attr)
    if self.purchase_order.present?
      purchase_order.try(attr)
    else
      self.try(attr)
    end
  end

  def total_amount
    t=0
    amount.each do |i|
      t+= i[:estimated_cost].to_f
    end
    t + items.map(&:estimated_cost).compact.sum
  end

  private
  def default_values
    self.paid||=false
  end

end
