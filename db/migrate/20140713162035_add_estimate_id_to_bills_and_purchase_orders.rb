class AddEstimateIdToBillsAndPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :bills, :estimate_id, :integer
    add_column :purchase_orders, :estimate_id, :integer

    add_index :bills, :estimate_id
    add_index :purchase_orders, :estimate_id

    Bill.where('project_id is NOT NULL').each do |b|
      b.update_column(:estimate_id, Project.find(b.project_id).committed_estimate.id)
    end

    PurchaseOrder.all.each do |p|
      p.update_column(:estimate_id, Project.find(b.project_id).committed_estimate.id)
    end
  end
end
