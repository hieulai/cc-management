class Invoice < ActiveRecord::Base
  acts_as_paranoid
  include Cacheable
  before_destroy :check_readonly

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :estimate

  has_many :invoices_items, :dependent => :destroy
  has_many :items, :through => :invoices_items
  has_many :invoices_bills_categories_templates, :dependent => :destroy
  has_many :receipts_invoices, :dependent => :destroy
  has_many :receipts, :through => :receipts_invoices
  has_many :accounting_transactions, as: :transactionable, :dependent => :destroy

  accepts_nested_attributes_for :invoices_items, :allow_destroy => true, reject_if: :unbillable_item
  accepts_nested_attributes_for :invoices_bills_categories_templates, :allow_destroy => true, reject_if: :unbillable_bills_categories_template
  attr_accessible :reference, :sent_date, :invoice_date, :estimate_id, :invoices_items_attributes, :remaining_amount,
                  :bill_from_date, :bill_to_date, :cached_total_amount, :invoices_bills_categories_templates_attributes
  default_scope order("created_at DESC")
  scope :unbilled, where('remaining_amount is NULL OR remaining_amount > 0')
  scope :billed, where('remaining_amount = 0')
  scope :date_range, lambda { |from_date, to_date| where('invoice_date >= ? AND invoice_date <= ?', from_date, to_date) }
  scope :project, lambda { |project_id| joins(:estimate).where('estimates.project_id = ?', project_id) }

  after_initialize :default_values
  before_save :check_reference
  before_update :check_total_amount_changed, :clear_old_data, :remove_old_transactions
  after_save :update_transactions

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
    self.receipts_invoices.any?
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
    accounting_transactions.create({account_id: builder.accounts_receivable_account.id, date: date, amount: amount.to_f})
    accounting_transactions.create({payer_id: estimate.project.client_id, payer_type: Client.name, date: date, amount: amount.to_f})
    accounting_transactions.create({payer_id: estimate.project.client_id, payer_type: Client.name, project_id: self.project.id, date: date, amount: amount.to_f})
  end

  def remove_old_transactions
    accounting_transactions.destroy_all
  end

  private
  def unbillable_item(attributes)
    attributes['item_id'].blank? || !Item.find(attributes['item_id'].to_i).billable?(self.id)
  end

  def unbillable_bills_categories_template(attributes)
    attributes['bills_categories_template_id'].blank? || !BillsCategoriesTemplate.find(attributes['bills_categories_template_id'].to_i).billable?(self.id)
  end

  def check_readonly
    if billed?
      errors[:base] << "This invoice is already paid and can not be deleted."
      false
    end
  end

  def check_total_amount_changed
    if !self.new_record? && self.billed? && self.amount!= self.read_attribute(:cached_total_amount)
      errors[:base] << "This invoice has already been paid in the amount of $#{self.read_attribute(:cached_total_amount)}. Editing a paid invoice requires that all item amounts continue to add up to the original receipt amount. If the original receipt was made for the wrong amount, correct the receipt first and then come back and edit the invoice."
      return false
    end
  end

  def check_reference
    if self.reference
      return true unless reference_changed?
      if self.class.where('id != ? and reference = ?', id, reference).any?
        errors[:base] << "Invoice # #{reference} is already used"
        return false
      end
    else
      self.reference = self.class.maximum(:reference).to_f + 1
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
