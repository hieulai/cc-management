class MigrateBidsItems < ActiveRecord::Migration
  def up
    count = 0
    Bid.all.each do |b|
      puts "Checking bill Id: #{b.id}"
      next unless b.amount
      begin
        b.amount.each do |i|
          if Item.exists?(i[:id]) && i[:uncommitted_cost].present?
            item = Item.find(i[:id])
            BidsItem.create(:item_id => item.id, :bid_id => b.id, :amount => i[:uncommitted_cost])
            puts "Created bids item item_id: #{item.id}, amount: #{i[:uncommitted_cost]}"
            count+=1
          end
        end
      rescue StandardError => e
        puts "Facing error #{e}, bid amount #{b.amount}"
      end
    end
  end

  def down
  end
end
