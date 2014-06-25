class AccountingTransaction < ActiveRecord::Base
  belongs_to :transactionable, polymorphic: true
  belongs_to :account

  attr_accessible :transactionable_id, :transactionable_type, :date, :amount, :reconciled, :account_id, :display_priority

  default_scope order("date DESC NULLS LAST, display_priority DESC, created_at DESC")
  scope :unreconciled, where(:reconciled => false)
  scope :reconciled, where(:reconciled => true)
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }

  PERSONABLE_CLASS = [Bill, Payment, Invoice, Receipt]

  searchable do
    text :payer_ids do
      payer_ids
    end
    text :payer_types do
      payer_types
    end
    text :project_ids do
      project_ids
    end
    date :date

    string :payer_ids, :multiple => true do
      payer_ids
    end
    string :payer_types, :multiple => true do
      payer_types
    end
    string :project_ids, :multiple => true do
      project_ids
    end
  end

  def amount(project_id = nil)
    project_id ? transactionable.amount(project_id) * (read_attribute(:amount) > 0 ? 1 : -1) : read_attribute(:amount)
  end

  def payer_ids
    personables.map(&:id) if personables
  end

  def payer_types
    personables.map { |p| p.class.name } if personables
  end

  def personables
    if PERSONABLE_CLASS.include? transactionable.class
      transactionable.personables(self).try(:compact)
    end
  end

  def project_ids
    if PERSONABLE_CLASS.include? transactionable.class
      personable_projects = transactionable.personable_projects
      personable_projects.compact.map(&:id)
    end
  end
end
