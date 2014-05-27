class MigrateInvoicesBillsToInvoicesBillsCategoriesTemplates < ActiveRecord::Migration
  def up
    InvoicesBill.all.each do |ib|
      ib.invoice.invoices_bills_categories_templates.create({bills_categories_template_id: ib.bill.bills_categories_templates.first.id,
                                                            amount: ib.amount})
      ib.destroy
    end
  end

  def down
  end
end
