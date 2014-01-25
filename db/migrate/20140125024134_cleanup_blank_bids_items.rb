class CleanupBlankBidsItems < ActiveRecord::Migration
  def up
    BidsItem.where(:amount => nil).destroy_all
  end

  def down
  end
end
