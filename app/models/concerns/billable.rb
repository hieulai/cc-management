module Billable
  extend ActiveSupport::Concern

  included do
    has_many :bills, as: :payer
    has_many :purchase_orders, as: :payer
    scope :has_unpaid_bills, joins(:bills).where("bills.remaining_amount is NULL OR bills.remaining_amount > 0").uniq

    after_save :update_billable_indexes
  end

  def update_billable_indexes
    Sunspot.delay.index bills
    Sunspot.delay.index purchase_orders
  end
end