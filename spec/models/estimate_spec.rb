require 'spec_helper'

describe Estimate do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:project) }
    it { expect(subject).to validate_presence_of(:builder) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :project }

    it { expect(subject).to have_many :measurements }
    it { expect(subject).to have_many :invoices }
    it { expect(subject).to have_many :bids }
    it { expect(subject).to have_many :specifications }
    it { expect(subject).to have_many :bills }
    it { expect(subject).to have_many :purchase_orders }
    it { expect(subject).to have_one :template }
  end

  describe "Behaviors" do
    context "has_bills" do
      subject { FactoryGirl.create :has_bills_estimate }
      it "should be undestroyable" do
        expect(subject.destroy).to be_false
      end
    end

    context "has_invoices" do
      subject { FactoryGirl.create :has_invoices_estimate }
      it "should be undestroyable" do
        expect(subject.destroy).to be_false
      end
    end

    context "when there is another commited one" do
      let(:committed_estimate) { FactoryGirl.create :committed_estimate }
      subject { FactoryGirl.build(:estimate, :project => committed_estimate.project, :builder => committed_estimate.builder, :committed => true) }
      it "should not be commited" do
        expect(subject.save).to be_false
      end
    end
  end

end
