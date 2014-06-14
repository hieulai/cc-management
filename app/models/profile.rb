class Profile < ActiveRecord::Base

  belongs_to :personable, polymorphic: true, touch: true
  belongs_to :person

  attr_accessible :first_name, :last_name, :email, :phone1, :phone2, :phone1_tag, :phone2_tag
  after_save :create_person, :if => Proc.new { |p| p.email.present? }

  default_scope order("created_at ASC")

  private
  def create_person
    self.update_column(:person_id, Person.where({email: self.email}).first_or_create.id)
  end
end
