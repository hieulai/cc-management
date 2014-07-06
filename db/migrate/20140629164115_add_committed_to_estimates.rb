class AddCommittedToEstimates < ActiveRecord::Migration
  def change
    add_column :estimates, :committed, :boolean

    Project.where(status: [Project::CURRENT, Project::PAST]).joins(:estimates).each do |p|
      p.estimates.first.update_attribute(:committed, true)
    end
  end
end
