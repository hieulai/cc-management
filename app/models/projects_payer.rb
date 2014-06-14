class ProjectsPayer < ActiveRecord::Base
  belongs_to :payer, polymorphic: true, touch: true
  belongs_to :project

  attr_accessible :payer_id, :payer_type, :project_id
end
