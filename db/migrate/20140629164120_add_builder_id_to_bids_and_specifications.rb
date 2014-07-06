class AddBuilderIdToBidsAndSpecifications < ActiveRecord::Migration
  def change
    add_column :bids, :builder_id, :integer
    add_column :specifications, :builder_id, :integer

    add_index :bids, :builder_id
    add_index :specifications, :builder_id

    Bid.all.each do |b|
      if b.project
        b.update_column(:builder_id, b.project.builder_id)
      else
        b.destroy
      end
    end

    Specification.all.each do |s|
      if s.project
        s.update_column(:builder_id, s.project.builder_id)
      else
        s.destroy
      end
    end
  end
end
