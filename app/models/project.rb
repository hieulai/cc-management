class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :estimates, :dependent => :destroy
  has_many :bids, :dependent => :destroy
  has_many :change_orders, :dependent => :destroy
  has_many :specifications, :dependent => :destroy
  has_many :purchase_orders, :dependent => :destroy
  has_many :bills, :dependent => :destroy
  has_one :tasklist, :dependent => :destroy
  has_many :invoices, :through => :estimates

  attr_accessible :name, :project_type, :status, :lead_stage, :progress, :revenue, :start_date, :completion_date,
  :deadline, :schedule_variance, :next_tasks, :check_back, :lead_source, :lead_notes, :project_notes
  default_scope order("name desc")

  def next_tasks n
    incomplete_tasks[0..n-1]
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
  
end
