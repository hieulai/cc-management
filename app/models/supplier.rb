class Supplier < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :builder
end
