class PurchaseOrdersItem < ActiveRecord::Base
  include Purchasable

  belongs_to :purchase_order
  attr_accessible :purchase_order_id
end
