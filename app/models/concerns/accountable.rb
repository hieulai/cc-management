module Accountable
  extend ActiveSupport::Concern

  included do
    attr_accessor :related_account
  end

  def account_amount
    (amount || 0) * (self.related_account.kind_of?(self.class.const_get("NEGATIVES")) ? -1 : 1)
  end

end