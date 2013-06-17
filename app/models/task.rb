class Task < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :tasklist
end
