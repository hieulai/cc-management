module Profileable
  extend ActiveSupport::Concern

  included do
    has_many :profiles, as: :profileable, dependent: :destroy
    has_many :payments, :as => :payer
    has_many :receipts, as: :payer
    has_many :projects_payers, :as => :payer, :dependent => :destroy

    accepts_nested_attributes_for :profiles, :projects_payers, :allow_destroy => true, reject_if: :all_blank
    attr_accessible :profiles_attributes, :projects_payers_attributes, :company, :website, :address, :city, :state, :zipcode, :notes

    after_touch :index
    after_save :update_profileable_indexes

    searchable do
      string :main_email do
        main_email
      end
      string :main_full_name do
        main_full_name
      end
      string :main_primary_phone do
        main_primary_phone
      end
      string :company_or_main_full_name do
        "#{company.to_s} #{main_full_name}"
      end
      string :company
      string :notes
      string :website
      string :project_names do
        project_names
      end

      text :company, :website, :notes
      text :main_email do
        main_email
      end
      text :main_full_name do
        main_full_name
      end
      text :main_primary_phone do
        main_primary_phone
      end
      text :company_or_main_full_name do
        "#{company.to_s} #{main_full_name}"
      end

      text :project_names do
        project_names
      end
    end
  end

  def primary_contact
    profiles.first
  end

  def main_email
    primary_contact.try :email
  end

  def main_first_name
    primary_contact.try :first_name
  end

  def main_last_name
    primary_contact.try :last_name
  end

  def main_full_name
    "#{main_first_name} #{main_last_name}"
  end

  def main_primary_phone
    primary_contact.try :phone1
  end

  def display_name
    company.presence || main_full_name
  end

  def project_names_from_checks
    names = []
    payments.each do |p|
      names << p.bills.map { |b| b.project.try(:name) }
    end
    names.flatten.uniq.join(",")
  end

  def project_names
    names = []
    names << project_names_from_checks if project_names_from_checks.present?
    projects_payers.each do |pp|
      names << pp.project.name
    end
    names.flatten.uniq.join(",")
  end

  def update_profileable_indexes
    Sunspot.delay.index payments
    Sunspot.delay.index receipts
  end

  module ClassMethods
    def import(file, builder = nil)
      spreadsheet = open_spreadsheet(file)
      if spreadsheet.first_row.nil?
        raise "There is no data in file"
      end
      header = spreadsheet.row(1).map! { |c| c.parameterize.underscore.strip }
      errors = []
      objects = []
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        object = find_by_id(row["id"]) || new
        attributes =  row.to_hash.slice(*accessible_attributes)
        object.attributes = attributes
        object.profiles.build({first_name: attributes['primary_first_name'],
                               last_name: attributes['primary_last_name'],
                               email: attributes['email'],
                               phone1: attributes['primary_phone1'],
                               phone1_tag: attributes['primary_phone1_tag'],
                               phone2: attributes['primary_phone2'],
                               phone2_tag: attributes['primary_phone2_tag']})

        object.profiles.build({first_name: attributes['secondary_first_name'],
                               last_name: attributes['secondary_last_name'],
                               email: attributes['secondary_email'],
                               phone1: attributes['secondary_phone1'],
                               phone1_tag: attributes['secondary_phone1_tag'],
                               phone2: attributes['secondary_phone2'],
                               phone2_tag: attributes['secondary_phone2_tag']})

        object.builder_id = builder.id if builder.present?
        unless object.save
          errors << "Importing Error at line #{i}: #{object.errors.full_messages}"
        else
          objects << object
        end
      end
      {errors: errors, objects: objects}
    end

    def open_spreadsheet(file)
      case File.extname(file.original_filename)
        when ".csv" then Roo::Csv.new(file.path,nil)
        when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
        when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
        else raise "Unknown file type: #{file[:data].original_filename}"
      end
    end
  end

end