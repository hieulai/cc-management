module Cacheable
  extend ActiveSupport::Concern

  included do
    after_save :update_cached_total_amount
  end

  def update_cached_total_amount
    update_column(:cached_total_amount, total_amount)
  end

end