module Personable
  extend ActiveSupport::Concern

  included do
    acts_as_paranoid

    belongs_to :builder, :class_name => "Base::Builder"
    belongs_to :company

    has_many :payments, :as => :payer, :dependent => :destroy
    has_many :receipts, as: :payer, :dependent => :destroy
    has_many :bills, as: :payer, :dependent => :destroy
    has_many :projects_payers, :as => :payer, :dependent => :destroy
    has_many :accounting_transactions, :as => :payer, :dependent => :destroy

    accepts_nested_attributes_for :projects_payers, :allow_destroy => true, reject_if: :all_blank
    attr_accessible :projects_payers_attributes, :website, :zipcode, :notes, :company_id
    delegate :company_name, :city, :state, :address, :company_name_with_address, to: :company, :allow_nil => true

    before_destroy :check_destroyable, :prepend => true

    validates_uniqueness_of :company_id, scope: [:builder_id], :allow_blank => :true

    # after_save :remove_old_company?

    searchable do
      string :company_name do
        company_name
      end
      string :notes
      string :project_names do
        project_names
      end
      string :display_name do
        display_name
      end

      text :notes
      text :company_name do
        company_name
      end
      text :project_names do
        project_names
      end
      text :display_name do
        display_name
      end
      float :balance, :trie => true do
        balance
      end
    end
  end

  def undestroyable?
    payments.any? || receipts.any? || bills.any? || purchase_orders.any?
  end

  def display_name
    company_name.presence || main_full_name
  end

  def has_projects?
    PaymentsBill.joins(:payment).where("payments.id in (?)", payments.pluck(:id)).joins(:bill).where("bills.job_costed = true").any? || projects_payers.any?
  end

  def associated_projects_from_checks
    payments.flat_map { |p| p.bills.job_costed.map { |b| b.project } }.uniq
  end

  def associated_projects_from_bills
    bills.job_costed.map { |b| b.project }.uniq
  end

  def associated_projects
    [associated_projects_from_checks, associated_projects_from_bills, projects_payers.map(&:project)].flatten.uniq
  end

  def project_names_from_checks
    associated_projects_from_checks.map(&:name).join(",")
  end

  def project_names
    associated_projects.compact.map(&:name).join(",")
  end

  def transactions(options ={})
    options ||= {}
    options[:project_id].present? ? accounting_transactions.project_accounts(options[:project_id]) : accounting_transactions.non_project_accounts
  end

  def balance(options ={})
    options ||= {}
    r = transactions(options)
    if options[:offset]
      ids = r.offset(options[:offset]).pluck(:id)
      r = AccountingTransaction.where(id: ids)
    end
    r.sum(:amount)
  end

  def check_destroyable
    if undestroyable?
      errors[:base] << "This #{self.class.name} has #{dependencies.join(", ")} associated with it. You must reallocate these #{dependencies.join(", ")}  to a different #{self.class.name} before you can delete this #{self.class.name}"
      false
    else
      true
    end
  end

  def dependencies
    dependencies = []
    dependencies << "payments" if payments.any?
    dependencies << "receipts" if receipts.any?
    dependencies << "bills" if bills.any?
    dependencies << "purchase orders" if purchase_orders.any?
    dependencies
  end
end