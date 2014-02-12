module AccountingHelper
  def grouped_category_options(project)
    return [] unless project
    result = []
    original_categories = []
    if project.estimates.any?
      project.estimates.each do |e|
        original_categories+= e.template.categories_templates.sort_by { |c| c.category.name }.map { |c| c.category }
      end
    end
    raw_categories = @builder.categories.raw.reject { |c| original_categories.map { |c| c[:name] }.include? c.name }
    result << ['From estimate', original_categories.map { |c| [c.name, c.id] }] if original_categories.any?
    result << ['New', raw_categories.map { |c| [c.name, c.id] }] if raw_categories.any?
    result
  end

  def bank_accounts
    asset_account = @builder.accounts.top.where(:name => Account::ASSETS).first
    bank_account = asset_account.children.where(:name => Account::BANK_ACCOUNTS).first
    @builder.accounts.where(:parent_id => bank_account.id)
  end

  def select2_bank_accounts_json
    json = []
    bank_accounts.each do |a|
      json << a.as_select2_json
    end
    json.to_json
  end

  def select2_receipt_gl_accounts_json
    json = []
    gl_accounts = @builder.accounts.top.where(:name => [Account::REVENUE, Account::LIABILITIES, Account::EQUITY, Account::ASSETS])
    gl_accounts.each do |a|
      filters = a.name == Account::ASSETS ? [Account::BANK_ACCOUNTS] : []
      json << a.as_select2_json(filters)
    end
    json.to_json
  end

  def select2_bill_gl_accounts_json
    json = []
    gl_accounts = @builder.accounts.top.where(:name => [Account::ASSETS, Account::EXPENSES, Account::LIABILITIES, Account::EQUITY])
    gl_accounts.each do |a|
      filters = a.name == Account::ASSETS ? [Account::BANK_ACCOUNTS] : []
      json << a.as_select2_json(filters)
    end
    json.to_json
  end
end
