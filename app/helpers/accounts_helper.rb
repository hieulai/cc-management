module AccountsHelper
  def select2_bank_transfer_accounts_json
    json = []
    bank_transfer_accounts = @builder.accounts.where(:name => Transfer::BANK_TRANSFERS).first.children
    bank_transfer_accounts.each do |a|
      json << a.as_select2_json
    end
    json.to_json
  end

  def select2_gl_transfer_accounts_json
    json = []
    gl_transfer_names = Account::DEFAULTS - Transfer::GL_TRANSFERS
    gl_transfer_accounts = @builder.accounts.where(:name => gl_transfer_names)
    gl_transfer_accounts.each do |a|
      json << a.as_select2_json(["Bank Accounts"])
    end
    json.to_json
  end
end
