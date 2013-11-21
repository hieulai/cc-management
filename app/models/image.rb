class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true

  attr_accessible :imageable_id, :imageable_type, :name
  mount_uploader :name, ImageUploader
end
