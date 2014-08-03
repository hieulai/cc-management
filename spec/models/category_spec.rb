require 'spec_helper'

describe Category do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:name) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to have_many :categories_templates }
    it { expect(subject).to have_many :change_orders_categories }
    it { expect(subject).to have_many :templates }
    it { expect(subject).to have_many :bids }
  end

  describe "Behaviors" do
    context "has paid categories templates" do
      subject { FactoryGirl.create :has_paid_categories_templates_category }
      it "should not be delete" do
        expect(subject.destroy).to be_false
      end
    end
  end

  context "has paid change orders" do
    subject { FactoryGirl.create :has_paid_change_orders_category }
    it "should not be delete" do
      expect(subject.destroy).to be_false
    end
  end

  context "has chosen bids" do
    subject { FactoryGirl.create :has_chosen_bids_category }
    it "should not be delete" do
      expect(subject.destroy).to be_false
    end
  end
end
