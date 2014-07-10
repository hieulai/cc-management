class ProjectsPayer < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :payer, polymorphic: true
  belongs_to :project

  attr_accessible :payer_id, :payer_type, :project_id

  after_touch :update_indexes
  after_destroy :update_indexes

  def update_indexes
    Sunspot.delay.index payer
  end
end
