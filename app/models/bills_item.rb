class BillsItem < ActiveRecord::Base
  include Purchasable

  belongs_to :bill
  attr_accessible :bill_id

end
