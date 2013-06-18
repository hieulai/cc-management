class Item < ActiveRecord::Base
  belongs_to :template
  belongs_to :builder
  belongs_to :category

  attr_accessible :name, :description, :qty, :unit, :cost, :margin, :price, :default, :notes

  def price
    #if cost ! nil & margin ! nil
     # cost + margin
    #else cost ! nil & margin = nil
     # cost
    #else
     # 0
    #end
  end
end
