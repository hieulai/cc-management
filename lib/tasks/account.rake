namespace :account do
  desc "Fix account balance"
  task :fix_balance, [:id] => :environment do |t, args|
    from_date = "1900-01-01"
    to_date = "3000-01-01"

    Account.all.each do |a|
      puts "  Fixing balance for Account: #{a.id}"
      balance = a.balance({from_date: from_date, to_date: to_date, recursive: false})
      puts "#{balance.to_f}"

      a.update_column(:balance, balance)
    end
  end
end