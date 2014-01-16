class AddFirstNameAndLastNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :first_name, :integer
    add_column :projects, :last_name, :string

    Project.all.each do |p|
      p.update_attribute(:name, p.read_attribute(:name))
    end
  end
end
