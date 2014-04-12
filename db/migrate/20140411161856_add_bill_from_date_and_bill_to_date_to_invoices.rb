class AddBillFromDateAndBillToDateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :bill_from_date, :date
    add_column :invoices, :bill_to_date, :date
  end
end
