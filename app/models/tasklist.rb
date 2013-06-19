class Tasklist < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :tasks
  belongs_to :project
end
