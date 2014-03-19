module Accounts
  class AccountHandler
    def self.get_account_handler(account)
      if account.default_account?
        return "#{Accounts.to_s}::#{account.name.delete(' ')}".constantize.new account
      end
      return Default.new account
    end
  end
end
