module AccountsHelper
  def select2_bank_transfer_accounts_json
    json = []
    asset_account = @builder.accounts.top.where(:name => Account::ASSETS).first
    bank_transfer_accounts = asset_account.children.where(:name => Transfer::BANK_TRANSFERS).first.children
    bank_transfer_accounts.each do |a|
      json << a.as_select2_json
    end
    json.to_json
  end

  def select2_gl_transfer_accounts_json
    json = []
    gl_transfer_names = Account::DEFAULTS - Transfer::GL_TRANSFERS
    gl_transfer_accounts = @builder.accounts.top.where(:name => gl_transfer_names)
    gl_transfer_accounts.each do |a|
      filters = a.name == Account::ASSETS ? [Account::BANK_ACCOUNTS] : []
      json << a.as_select2_json(filters)
    end
    json.to_json
  end
end
