module Importable
  extend ActiveSupport::Concern

  included do
    def self.import(file, builder = nil)
      spreadsheet = open_spreadsheet(file)
      if spreadsheet.first_row.nil?
        raise "There is no data in file"
      end
      header = spreadsheet.row(1).map! { |c| c.downcase.strip }
      errors = []
      objects = []
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        object = find_by_id(row["id"]) || new
        object.attributes = row.to_hash.slice(*accessible_attributes)
        object.builder_id = builder.id if builder.present?
        unless object.save
          errors << "Importing Error at line #{i}: #{object.errors.full_messages}"
        else
          objects << object
        end
      end
      {errors: errors, objects: objects}
    end

    def self.open_spreadsheet(file)
      case File.extname(file.original_filename)
        when ".csv" then Roo::Csv.new(file.path,nil)
        when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
        when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
        else raise "Unknown file type: #{file[:data].original_filename}"
      end
    end
  end
end