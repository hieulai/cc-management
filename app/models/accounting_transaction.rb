class AccountingTransaction < ActiveRecord::Base
  belongs_to :transactionable, polymorphic: true
  belongs_to :account

  attr_accessible :transactionable_id, :transactionable_type, :date, :amount, :reconciled, :account_id, :display_priority

  default_scope order("date DESC NULLS LAST, display_priority DESC, created_at DESC")
  scope :unreconciled, where(:reconciled => false)
  scope :reconciled, where(:reconciled => true)
  scope :date_range, lambda { |from_date, to_date| where('date >= ? AND date <= ?', from_date, to_date) }

  PERSONABLE_CLASS = [Bill, Payment, Invoice, Receipt]
  PROJECTABLE_CLASS = [Bill, Invoice]

  searchable do
    text :payer_ids do
      payer_ids
    end
    text :payer_types do
      payer_types
    end
    text :project_id do
      project_id
    end
    date :date

    string :payer_ids, :multiple => true do
      payer_ids
    end
    string :payer_types, :multiple => true do
      payer_types
    end
    string :project_id do
      project_id
    end
  end

  def payer_ids
    personables.map(&:id) if personables
  end

  def payer_types
    personables.map { |p| p.class.name } if personables
  end

  def personables
    transactionable.personables.try(:compact) if PERSONABLE_CLASS.include? transactionable.class
  end

  def project_id
    transactionable.try(:project).try(:id) if PROJECTABLE_CLASS.include? transactionable.class
  end
end
