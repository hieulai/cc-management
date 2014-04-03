class RemoveObsoleteTransfers < ActiveRecord::Migration
  def up
    Transfer.all.each do |t|
      next if t.from_account && t.to_account
      puts t.id
      t.destroy

    end
  end

  def down
  end
end
