class Architect < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :builder
end
