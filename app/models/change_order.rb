class ChangeOrder < ActiveRecord::Base
  belongs_to :builder
  belongs_to :project
  belongs_to :categories_template

  validates :name, presence: true

  after_initialize :default_values

  attr_accessible :cost, :description, :margin, :name, :notes, :qty, :unit, :categories_template_id

  def committed_cost
    self.cost * self.qty
  end

  def committed_profit
    self.margin * self.qty
  end

  private
  def default_values
    self.name||= "Change Order"
    self.qty||= 1
  end
end
