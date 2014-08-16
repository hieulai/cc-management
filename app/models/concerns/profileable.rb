module Profileable
  extend ActiveSupport::Concern

  included do
    has_many :profiles, as: :profileable, dependent: :destroy
    accepts_nested_attributes_for :profiles, :allow_destroy => true,
                                  reject_if: proc { |attributes|
                                    attributes['first_name'].blank? &&
                                        attributes['last_name'].blank? &&
                                        attributes['email'].blank? &&
                                        attributes['phone1'].blank? &&
                                        attributes['phone2'].blank? }
    attr_accessible :profiles_attributes
    after_touch :index

    after_save :update_profileable_indexes
    after_destroy :update_profileable_indexes

    searchable do
      string :primary_email do
        primary_email
      end
      string :main_full_name do
        main_full_name
      end
      string :primary_phone1 do
        primary_phone1
      end

      text :primary_email do
        primary_email
      end
      text :main_full_name do
        main_full_name
      end
      text :primary_phone1 do
        primary_phone1
      end
      text :company_or_main_full_name do
        "#{company.to_s} #{main_full_name}"
      end
    end
  end

  def primary_contact
    profiles.first
  end

  def secondary_contact
    profiles.last
  end

  def main_full_name
    "#{primary_first_name} #{primary_last_name}"
  end

  def display_name
    company.presence || main_full_name
  end

  [:first_name, :last_name, :email, :phone1, :phone1_tag, :phone2, :phone2_tag].each do |a|
    define_method("primary_#{a.to_s}") do
      primary_contact.try a
    end

    define_method("secondary_#{a.to_s}") do
      secondary_contact.try a
    end
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