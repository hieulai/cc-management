module Billable
  extend ActiveSupport::Concern

  included do
    has_many :bills, as: :payer
    has_many :purchase_orders, as: :payer
    after_save :update_billable_indexes
  end

  def update_billable_indexes
    Sunspot.delay.index bills
    Sunspot.delay.index purchase_orders
  end
end