class Project < ActiveRecord::Base
  CURRENT = 'Current Project'
  PAST =  "Past Project"
  CURRENT_LEAD = 'Current Lead'
  PAST_LEAD = 'Past Lead'
  acts_as_paranoid
  before_destroy :check_destroyable

  belongs_to :client, touch: true
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :estimates, :dependent => :destroy
  has_many :change_orders, :dependent => :destroy
  has_many :projects_payers, :dependent => :destroy
  has_one :tasklist, :dependent => :destroy
  has_many :invoices, :through => :estimates

  attr_accessible :name, :first_name, :last_name, :project_type, :status, :lead_stage, :progress, :revenue, :start_date, :completion_date,
                  :deadline, :schedule_variance, :next_tasks, :check_back, :lead_source, :lead_notes, :project_notes, :client_id
  default_scope order("first_name asc, last_name asc")
  scope :current_lead, where(status: CURRENT_LEAD)
  scope :past_lead, where(status: PAST_LEAD)
  scope :current_project, where(status: CURRENT)
  scope :past_project, where(status: PAST)
  scope :has_estimate, includes(:estimates).where("estimates.id IS NOT NULL AND estimates.deleted_at IS NULL")

  before_save :toggle_committed_estimate, :if => :status_changed?

  after_initialize :default_values
  after_save :update_client_status, :if => :status_changed?
  after_save :update_estimate_status, :if => :status_changed?
  after_save :update_indexes
  after_save :update_transactions, :if => :client_id_changed?

  validates :name, presence: true

  def undestroyable?
    estimates.select { |e| e.undestroyable? }.any?
  end

  def next_tasks n
    incomplete_tasks[0..n-1]
  end

  def name
    "#{self.first_name} #{self.last_name}".strip
  end

  alias name_before_type_cast name

  def name=(n)
    if /\d+\s\w+/.match(n)
      split = n.split(' ', 2)
      self.first_name = split.first.to_i
      self.last_name = split.last
    else
      self.last_name= n
    end
  end

  def current_progress
    if tasklist.present? && tasklist.tasks.any?
     (1 - incomplete_tasks.count.to_f/tasklist.tasks.count.to_f)*100.00
    else
      0.00
    end
  end

  def incomplete_tasks
    unless tasklist.nil?
      tasklist.tasks.select { |t| !t.completed? }
    else
      Array.new
    end
  end

  def co_items(category)
    co_categories = ChangeOrdersCategory.where(:change_order_id => change_orders.approved.pluck(:id))
    co_categories.reject! { |co_category| co_category.category.try(:name) != category.name }
    co_categories.map(&:items).flatten
  end

  def cos_categories
    template = committed_estimate.template
    categories = Category.where(:id => template.categories_templates.pluck(:category_id))
    co_categories = ChangeOrdersCategory.where(:change_order_id => change_orders.approved.pluck(:id)).uniq
    cos_categories = co_categories.map(&:category).compact.uniq
    cos_categories.reject! { |c| categories.pluck(:name).include? c.name } || Array.new
  end

  def committed_estimate
    estimates.commitments.first
  end

  def update_indexes
    estimates.each do |e|
      Sunspot.delay.index e.bills
      Sunspot.delay.index e.purchase_orders
      Sunspot.delay.index e.invoices
    end
    projects_payers.each { |pp| pp.touch }
  end

  def update_client_status
    case self.status
      when Project::CURRENT, Project::PAST
        #Allows client to display in the People section if the project is won.
        client.update_attributes(:status => Client::ACTIVE)
      when Project::CURRENT_LEAD, Project::PAST_LEAD
        #Prevents client from displaying in the People section if the project is not won yet.
        client.update_attributes(:status => Client::LEAD)
    end
  end

  def toggle_committed_estimate
    if [Project::CURRENT, Project::PAST].include?(self.status_was) &&
        [Project::CURRENT_LEAD, Project::PAST_LEAD].include?(self.status)
      committed_estimate.update_attributes(:committed => nil)
      true
    elsif [Project::CURRENT_LEAD, Project::PAST_LEAD].include?(self.status_was) &&
        [Project::CURRENT, Project::PAST].include?(self.status)
      if self.estimates.size == 1
        estimates.first.update_attributes(:committed => true)
        true
      elsif estimates.commitments.empty?
        errors[:base] << "An estimate must be created before a project can be made active."
        false
      end
    end
  end

  def update_estimate_status
    if [PAST].include?(self.status)
      estimates.each do |e|
        e.update_attributes(:status => Estimate::PAST)
      end
    elsif [CURRENT].include?(self.status)
      estimates.each do |e|
        e.update_attributes(:status => Estimate::CURRENT)
      end
    end
  end

  def default_values
    status ||= CURRENT_LEAD
  end

  def update_transactions
    invoices.each { |i| i.save }
    receipts = invoices.map(&:receipts).flatten.compact.uniq
    receipts.each do |r|
      r.update_attributes(:client_id => r.invoices.project(self.id).first.project.client_id)
    end
  end

  def check_destroyable
    if undestroyable?
      errors[:base] << "This project cannot be deleted once containing undestroyable estimates."
      false
    else
      true
    end
  end
end
