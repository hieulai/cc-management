require 'spec_helper'

describe Company do
  describe "Validations" do
    # it { expect(subject).to validate_uniqueness_of(:company_name).scoped_to(:city, :state, :type) }

    context "if company_name" do
      before { subject.stub(:company_name) { "acme" } }
      it { expect(subject).to validate_presence_of(:city) }
      it { expect(subject).to validate_presence_of(:state) }
    end

    context "if no company_name" do
      it { expect(subject).not_to validate_presence_of(:city) }
      it { expect(subject).not_to validate_presence_of(:state) }
    end
  end

  describe "Associations" do
    it { expect(subject).to have_one :image }
  end
end
