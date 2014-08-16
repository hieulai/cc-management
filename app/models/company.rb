# == Schema Information
#
# Table name: companies
#
#  id           :integer          not null, primary key
#  company_name :string(255)
#  year_founded :integer
#  office_phone :string(255)
#  website      :string(255)
#  address      :string(255)
#  city         :string(255)
#  state        :string(255)
#  zipcode      :string(255)
#  tax_id       :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  slogan       :string(255)
#  logo         :string(255)
#  type         :string(255)
#  deleted_at   :time
#

class Company < ActiveRecord::Base
  acts_as_paranoid
  has_one :image, as: :imageable, dependent: :destroy

  attr_accessible :type, :company_name, :year_founded, :office_phone, :website, :address, :city, :state, :zipcode, :tax_id, :logo, :slogan, :image_attributes, :notes
  accepts_nested_attributes_for :image

  validates_uniqueness_of :company_name, scope: [:city, :state, :type]
  validates_presence_of :company_name

  def self.lookup(params)
    query = {}
    query[:company_name] = params[:company_name]
    query[:city] = params[:city] if params[:city]
    query[:state] = params[:city] if params[:state]
    self.where(query).first_or_create
  end
end
