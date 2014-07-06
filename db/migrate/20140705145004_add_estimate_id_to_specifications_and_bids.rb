class AddEstimateIdToSpecificationsAndBids < ActiveRecord::Migration
  def change
    add_column :specifications, :estimate_id, :integer
    add_column :bids, :estimate_id, :integer

    add_index :specifications, :estimate_id
    add_index :bids, :estimate_id

    Specification.all.each do |s|
      if s.project
        s.update_column(:estimate_id, s.project.committed_estimate.id)
      else
        s.destroy
      end
    end

    Bid.all.each do |b|
      if b.project
        b.update_column(:estimate_id, b.project.committed_estimate.id)
      else
        b.destroy
      end
    end
  end
end
