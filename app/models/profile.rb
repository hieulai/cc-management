# == Schema Information
#
# Table name: profiles
#
#  id               :integer          not null, primary key
#  person_id        :integer
#  builder_id       :integer
#  first_name       :string(255)
#  last_name        :string(255)
#  email            :string(255)
#  phone1           :string(255)
#  phone1_tag       :string(255)
#  phone2           :string(255)
#  phone2_tag       :string(255)
#  profileable_id   :integer
#  profileable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :time
#

class Profile < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :profileable, polymorphic: true, touch: true
  belongs_to :person

  attr_accessible :builder_id, :first_name, :last_name, :email, :phone1, :phone2, :phone1_tag, :phone2_tag

  default_scope order("created_at ASC")
  after_save :create_person, :if => Proc.new { |p| p.email.present? }
  validates_uniqueness_of :email, scope: [:builder_id], :allow_blank => :true

  private
  def create_person
    self.update_column(:person_id, Person.where({email: self.email}).first_or_create.id)
  end
end
