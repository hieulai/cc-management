# == Schema Information
#
# Table name: images
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  imageable_id   :integer
#  imageable_type :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Image < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true

  attr_accessible :imageable_id, :imageable_type, :name
  mount_uploader :name, ImageUploader
end
