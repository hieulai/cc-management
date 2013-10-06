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

  private
  def default_values
    self.paid||=false
    self.sales_tax_rate||=8.25
  end
end
