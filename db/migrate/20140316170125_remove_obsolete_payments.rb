class RemoveObsoletePayments < ActiveRecord::Migration
  def up
    Payment.all.each do |p|
      unless p.account
        puts p.id
        p.destroy
      end
    end
  end

  def down
  end
end
