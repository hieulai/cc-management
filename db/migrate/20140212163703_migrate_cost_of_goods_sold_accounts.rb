class MigrateCostOfGoodsSoldAccounts < ActiveRecord::Migration
  def up
    # Create Cost of Goods Sold accounts for categories templates
    CategoriesTemplate.all.each do |ct|
      builder = ct.template.estimate.try(:builder)
      next unless builder
      ct.revenue_account
      ct.cogs_account
    end

    # Create Cost of Goods Sold accounts for change_orders categories
    ChangeOrdersCategory.all.each do |coc|
      coc.revenue_account
      coc.cogs_account
    end

    # Migrate bills amount
    Bill.joins(:categories_template).each do |b|
      b.increase_account
    end

    # Migrate invoices amount
    InvoicesItem.all.each do |ii|
      ii.increase_account
    end
  end

  def down
  end
end
