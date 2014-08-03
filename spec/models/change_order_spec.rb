require 'spec_helper'

describe ChangeOrder do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:name) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :project }
    it { expect(subject).to have_many :change_orders_categories }
  end

  describe "Behaviors" do
    context "has paid items" do
      subject { FactoryGirl.create :has_billed_items_change_order }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
      it "should not be disapproved" do
        expect(subject.update_attribute(:approved, false)).to be_false
      end
    end

    context "has invoiced items" do
      subject { FactoryGirl.create :has_invoiced_items_change_order }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
      it "should not be disapproved" do
        expect(subject.update_attribute(:approved, false)).to be_false
      end
    end
  end
end
