class Project < ActiveRecord::Base

  belongs_to :client, touch: true
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :estimates, :dependent => :destroy
  has_many :bids, :dependent => :destroy
  has_many :change_orders, :dependent => :destroy
  has_many :specifications, :dependent => :destroy
  has_many :purchase_orders, :dependent => :destroy
  has_many :projects_payers, :dependent => :destroy
  has_many :bills, :dependent => :destroy
  has_one :tasklist, :dependent => :destroy
  has_many :invoices, :through => :estimates

  attr_accessible :name, :first_name, :last_name, :project_type, :status, :lead_stage, :progress, :revenue, :start_date, :completion_date,
  :deadline, :schedule_variance, :next_tasks, :check_back, :lead_source, :lead_notes, :project_notes
  default_scope order("first_name asc, last_name asc")
  scope :current_lead, where(status: "Current Lead")
  scope :past_lead, where(status: "Past Lead")
  scope :current_project, where(status: "Current Project")
  scope :past_project, where(status: "Past Project")
  scope :has_estimate, includes(:estimates).where("estimates.id IS NOT NULL")

  after_save :update_indexes

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
    template = estimates.first.template
    categories = Category.where(:id => template.categories_templates.pluck(:category_id))
    co_categories = ChangeOrdersCategory.where(:change_order_id => change_orders.approved.pluck(:id)).uniq
    cos_categories = co_categories.map(&:category).uniq
    cos_categories.reject! { |c| categories.pluck(:name).include? c.name } || Array.new
  end

  def update_indexes
    Sunspot.delay.index bills
    Sunspot.delay.index purchase_orders
    Sunspot.delay.index invoices
    projects_payers.each { |pp| pp.touch }
  end
  
end
