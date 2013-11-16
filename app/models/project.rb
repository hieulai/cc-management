class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :builder
  has_many :estimates
  has_many :bids
  has_many :change_orders
  has_many :specifications
  has_many :purchase_orders
  has_one :tasklist
  has_many :invoices, :through => :estimates

  attr_accessible :name, :project_type, :status, :lead_stage, :progress, :revenue, :start_date, :completion_date,
  :deadline, :schedule_variance, :next_tasks, :check_back, :lead_source, :lead_notes, :project_notes

  def next_tasks n
    incompleted_tasks[0..n-1]
  end

  def current_progress
    if tasklist.present? && tasklist.tasks.any?
     (1 - incompleted_tasks.count.to_f/tasklist.tasks.count.to_f)*100.00
    else
      0.00
    end
  end

  def incompleted_tasks
    unless tasklist.nil?
      tasklist.tasks.select { |t| !t.completed? }
    else
      Array.new
    end
  end

  def co_items(category)
    co_categories = ChangeOrdersCategory.where(:change_order_id => change_orders.approved.pluck(:id))
    co_categories.reject! { |co_category| co_category.category.name != category.name }
    co_categories.map(&:items).flatten
  end

  def co_categories(template)
    categories = Category.where(:id => template.categories_templates.pluck(:category_id))
    co_categories = ChangeOrdersCategory.where(:change_order_id => change_orders.approved.pluck(:id))
    co_categories.reject! { |co_category| categories.pluck(:name).include? co_category.category.name }
  end
  
end
