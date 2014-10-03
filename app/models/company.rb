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

  # validates_uniqueness_of :company_name, scope: [:city, :state, :type], :allow_blank => :true

  validates_presence_of :city, :state, :if => Proc.new { |c| c.company_name.present? }

  def self.lookup(params)
    return nil if params[:company_name].blank? && params[:city].blank? && params[:state].blank? && params[:address].blank?
    query = {}
    query[:company_name] = params[:company_name] if params[:company_name]
    query[:city] = params[:city] if params[:city]
    query[:state] = params[:state] if params[:state]
    query[:address] = params[:address] if params[:address]
    self.where(query).first_or_create
  end

  def company_name_with_address
    Company.where('company_name =  ? AND type = ? AND id !=?', company_name, type, id).any? ? "#{company_name} (#{city }, #{state})" : company_name
  end
end
