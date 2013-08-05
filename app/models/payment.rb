class Payment < ActiveRecord::Base
  belongs_to :account
  belongs_to :vendor
  
  attr_accessible :amount, :date, :memo, :vendor_name
  
  def vendor_name
    vendor.try(:trade)
  end
  
  def vendor_name=(trade)
    self.vendor = Vendor.find_by_trade(trade) if trade.present?  
  end
end
