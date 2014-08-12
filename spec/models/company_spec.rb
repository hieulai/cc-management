require 'spec_helper'

describe Company do
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:company_name) }
    it { expect(subject).to validate_uniqueness_of(:company_name).scoped_to(:city, :state, :type) }
  end

  describe "Associations" do
    it { expect(subject).to have_one :image }
  end
end
