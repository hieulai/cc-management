class AddEstimateIdToSpecificationsAndBids < ActiveRecord::Migration
  def change
    add_column :specifications, :estimate_id, :integer
    add_column :bids, :estimate_id, :integer

    add_index :specifications, :estimate_id
    add_index :bids, :estimate_id

    Specification.all.each do |s|
        s.update_column(:estimate_id, s.project.committed_estimate.id)
    end

    Bid.all.each do |b|
      b.update_column(:estimate_id, b.project.committed_estimate.id)
    end
  end
end
