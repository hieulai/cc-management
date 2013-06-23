class Item < ActiveRecord::Base
  belongs_to :template
  belongs_to :builder
  has_and_belongs_to_many :categories

  attr_accessible :name, :description, :qty, :unit, :cost, :margin, :price, :default, :notes

  validates :name, presence: true

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
