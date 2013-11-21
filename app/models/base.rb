module Base
  class Builder < ActiveRecord::Base
    has_one :image, as: :imageable, dependent: :destroy

    #Relations
    has_many :clients
    has_many :projects
    has_many :estimates
    has_many :users
    has_many :items
    has_many :categories
    has_many :templates
    has_many :accounts
    has_many :tasklists
    has_many :vendors
    has_many :contacts
    has_many :prospects

    attr_accessible :company_name, :year_founded, :office_phone, :website, :address, :city, :state, :zipcode, :tax_id, :logo, :slogan, :image_attributes
    accepts_nested_attributes_for :image

  end

end