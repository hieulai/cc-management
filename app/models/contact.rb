class Contact < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :builder, :class_name => "Base::Builder"
  has_many :receipts, as: :payer

  attr_accessible :primary_first_name, :primary_last_name, :primary_email, :primary_phone1, :primary_phone2, :address, :city, :state, :zipcode, :notes,
                  :primary_phone1_tag, :primary_phone2_tag
  scope :search_by_name, lambda { |q|
    (q ? where(["primary_first_name ILIKE ? or primary_last_name ILIKE ? or concat(primary_first_name, ' ', primary_last_name) ILIKE ?", '%'+ q + '%','%'+ q + '%' ,'%'+ q + '%' ])  : {})
  }
     
  def full_name
      "#{primary_first_name} #{primary_last_name}"
  end

end
