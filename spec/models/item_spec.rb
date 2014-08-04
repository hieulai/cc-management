require 'spec_helper'

describe Item do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:name) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :change_orders_category }
    it { expect(subject).to belong_to :bills_categories_template }
    it { expect(subject).to belong_to :purchase_orders_categories_template }

    it { expect(subject).to have_many :invoices_items }
    it { expect(subject).to have_many :invoices }
    it { expect(subject).to have_many :bills_items }
    it { expect(subject).to have_many :purchase_orders_items }
    it { expect(subject).to have_many :bids_items }
    it { expect(subject).to have_many :bids }
    it { expect(subject).to have_and_belong_to_many :categories_templates }
  end

  describe "Behaviors" do
    context "belongs to bills" do
      subject { FactoryGirl.create :has_bills_item }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end

      it "should not be changed details" do
        expect(subject.update_attribute(:name, "smt")).to be_false
      end
    end

    context "belongs to invoices" do
      subject { FactoryGirl.create :has_invoices_item }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
      it "should not be changed details" do
        expect(subject.update_attribute(:name, "smt")).to be_false
      end
    end

    context "belongs to bids" do
      subject { FactoryGirl.create :has_bids_item }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
      it "should not be changed details" do
        expect(subject.update_attribute(:name, "smt")).to be_false
      end
    end
  end
end
