module Billable
  extend ActiveSupport::Concern

  included do
    has_many :bills, as: :payer
    scope :has_unpaid_bills, joins(:bills).where("bills.remaining_amount is NULL OR bills.remaining_amount > 0").uniq
  end
end