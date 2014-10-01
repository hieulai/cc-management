# == Schema Information
#
# Table name: invoices
#
#  id                  :integer          not null, primary key
#  builder_id          :integer
#  estimate_id         :integer
#  sent_date           :date
#  reference           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  remaining_amount    :decimal(10, 2)
#  invoice_date        :date
#  bill_from_date      :date
#  bill_to_date        :date
#  cached_total_amount :decimal(10, 2)
#  deleted_at          :time
#

class Invoice < ActiveRecord::Base
  acts_as_paranoid
  include Cacheable

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :estimate

  has_many :invoices_accounts, :dependent => :destroy
  has_many :invoices_items, :dependent => :destroy
  has_many :items, :through => :invoices_items
  has_many :invoices_bills_categories_templates, :dependent => :destroy
  has_many :receipts_invoices, :dependent => :destroy
  has_many :receipts, :through => :receipts_invoices
  has_many :accounting_transactions, as: :transactionable, :dependent => :destroy

  accepts_nested_attributes_for :invoices_items, :allow_destroy => true, reject_if: :unbillable_item
  accepts_nested_attributes_for :invoices_bills_categories_templates, :allow_destroy => true, reject_if: :invalid_bills_categories_template
  attr_accessible :reference, :sent_date, :invoice_date, :estimate_id, :invoices_items_attributes, :remaining_amount,
                  :bill_from_date, :bill_to_date, :cached_total_amount, :invoices_bills_categories_templates_attributes

  default_scope order("invoice_date ASC, reference ASC")
  scope :unbilled, where('remaining_amount is NULL OR remaining_amount != 0')
  scope :billed, where('remaining_amount = 0')
  scope :date_range, lambda { |from_date, to_date| where('invoice_date >= ? AND invoice_date <= ?', from_date, to_date) }
  scope :project, lambda { |project_id| joins(:estimate).where('estimates.project_id = ?', project_id) }
  scope :client, lambda { |client_id| joins(:estimate => :project).where('projects.client_id = ?', client_id) }
  scope :estimate, lambda { |estimate_id| where(estimate_id: estimate_id) }

  after_initialize :default_values
  before_save :check_reference
  before_save :check_date_range, :if => Proc.new { |i| i.estimate.cost_plus_bid? && i.bill_from_date && i.bill_to_date }
  before_update :check_total_amount_changed, :clear_old_data, :remove_old_transactions
  before_destroy :check_destroyable, :prepend => true
  after_save :update_transactions, :update_remaining_amount, :charge_client_credit_account

  validates_presence_of :estimate, :builder

  searchable do
    date :invoice_date
    date :sent_date
    integer :builder_id
    integer :reference
    string :project_name do
      project_name
    end
    float :amount do
      amount
    end

    text :reference
    text :id_t do |i|
      i.id.to_s
    end
    text :amount_t do
      sprintf('%.2f', amount.to_f)
    end
    text :sent_date_t do |i|
      i.sent_date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :invoice_date_t do |i|
      i.invoice_date.try(:strftime, Date::DATE_FORMATS[:default])
    end
    text :project_name do
      project_name
    end
  end

  def project_name
    project.name
  end

  def billed?
    self.receipts.any?
  end

  def full_billed?
    remaining_amount == 0
  end

  def amount
    if invoices_items.any?
      invoices_items.reject(&:marked_for_destruction?).map(&:amount).compact.sum
    elsif invoices_bills_categories_templates.any?
      invoices_bills_categories_templates.reject(&:marked_for_destruction?).map(&:amount).compact.sum
    end
  end

  def total_amount
    amount
  end

  def billed_amount
    self.receipts_invoices.map(&:amount).compact.sum if self.receipts_invoices.any?
  end

  def receipt_invoice(receipt_id)
    self.receipts_invoices.where(:receipt_id => receipt_id).first
  end

  def date
    invoice_date
  end

  def project
    estimate.project
  end

  def update_transactions
    accounting_transactions.create(account_id: builder.accounts_receivable_account.id, date: date, amount: amount.to_f)
    accounting_transactions.create(account_id: builder.accounts_receivable_account.id, project_id: self.project.id, date: date, amount: amount.to_f)
    accounting_transactions.create(payer_id: project.client_id, payer_type: Client.name, date: date, amount: amount.to_f)
    accounting_transactions.create(payer_id: project.client_id, payer_type: Client.name, project_id: self.project.id, date: date, amount: amount.to_f)
  end

  def remove_old_transactions
    accounting_transactions.destroy_all
  end

  def update_remaining_amount
    update_column(:remaining_amount, total_amount.to_f - billed_amount.to_f)
  end

  def charge_client_credit_account
    raw_ats = AccountingTransaction.where(account_id: builder.client_credit_account.id, payer_type: Client.name, payer_id: project.client_id)
    ats = raw_ats.non_project_accounts + raw_ats.project_accounts(project.id)
    ats.sort_by! { |at| at.date }
    applied_amount = amount
    ats.each do |at|
      break if applied_amount == 0
      at.transactionable.allocate_invoices
      at.transactionable.remove_old_transactions
      at.transactionable.update_transactions
      reload
      applied_amount = (applied_amount- billed_amount).round(2)
    end
  end

  private
  def unbillable_item(attributes)
    attributes['item_id'].blank? || !Item.find(attributes['item_id'].to_i).billable?(self.id)
  end

  def invalid_bills_categories_template(attributes)
    attributes['bills_categories_template_id'].blank? || !BillsCategoriesTemplate.find(attributes['bills_categories_template_id'].to_i).billable?(id)
  end

  def check_destroyable
    if billed?
      errors[:base] << "This invoice is already paid and can not be deleted."
      false
    end
  end

  def check_total_amount_changed
    if !new_record? && billed?
      ba = [billed_amount, cached_total_amount].min
      if amount < ba
        errors[:base] << "This invoice has already been paid in the amount of $#{billed_amount}. Editing a paid invoice requires that all item amounts continue to add up to the original receipt amount. If the original receipt was made for the wrong amount, correct the receipt first and then come back and edit the invoice."
        return false
      end
    end
  end

  def check_reference
    if self.reference
      return true unless reference_changed?
      reference_invoice = Invoice.where(:reference => reference).first
      if reference_invoice.present? && reference_invoice.id != id
        errors[:base] << "Invoice # #{reference} is already used"
        return false
      end
    else
      self.reference = self.class.maximum(:reference).to_f + 1
    end
  end

  def check_date_range
    invoices_bills_categories_templates.each do |ibct|
      ibct.destroy if !ibct.bills_categories_template.bill.billed_date.between?(bill_from_date, bill_to_date)
    end
  end

  def clear_old_data
    if self.estimate.cost_plus_bid?
      self.invoices_items.destroy_all
    else
      self.invoices_bills_categories_templates.destroy_all
      self.bill_from_date = nil
      self.bill_to_date = nil
    end
  end

  def default_values
    self.invoice_date ||= Date.today
  end
end
