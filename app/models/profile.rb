class Profile < ActiveRecord::Base

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :profileable, polymorphic: true, touch: true
  belongs_to :person

  attr_accessible :builder_id, :first_name, :last_name, :email, :phone1, :phone2, :phone1_tag, :phone2_tag

  default_scope order("created_at ASC")
  after_save :create_person, :if => Proc.new { |p| p.email.present? }
  validates_uniqueness_of :email, scope: [:builder_id]

  private
  def create_person
    self.update_column(:person_id, Person.where({email: self.email}).first_or_create.id)
  end
end
