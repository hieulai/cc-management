class Tasklist < ActiveRecord::Base
  # attr_accessible :title, :body
  has_mans :tasks
  belongs_to :project
end
