module Invoiceable
  extend ActiveSupport::Concern

  included do
  end

  def invoiceable_type
    Invoice.name.pluralize.concat(self.class.name).constantize
  end

  def invoiceables
    send Invoice.name.underscore.pluralize.concat("_").concat(self.class.name.underscore.pluralize).to_sym
  end

  def invoice_amount
    i = invoiceables
    i.map(&:amount).compact.sum if i.any?
  end

  def invoiceable(invoice_id)
    self.invoiceables.where(:invoice_id => invoice_id).first
  end

  def billed?
    self.invoices.any?
  end

  def billable?(invoice_id =nil)
    invoiceable(invoice_id).present? || invoice_amount.nil? || billable_amount > 0
  end

  def billable_amount
    price.to_f - invoice_amount.to_f
  end

  def prior_amount(invoice_id)
    previous_invoiceable = invoiceable_type.where(self.class.name.underscore.concat("_id").to_sym => id)
    if invoice_id.present?
      first_invoiceable = invoiceable(invoice_id)
      if first_invoiceable.present?
        previous_invoiceable = invoiceable_type.previous_created(id, first_invoiceable.created_at)
      end
    end
    previous_invoiceable.map(&:amount).compact.sum if previous_invoiceable.any?
  end
end