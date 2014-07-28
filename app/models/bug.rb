class Bug
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [:title, :description, :priority, :kind]
  attr_accessor *ATTRIBUTES

  validates :title, presence: true
  validates :description, presence: true

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end

  def persisted?
    false
  end

end