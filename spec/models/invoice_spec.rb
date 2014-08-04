require 'spec_helper'

describe Invoice do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:builder) }
    it { expect(subject).to validate_presence_of(:estimate) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :estimate }

    it { expect(subject).to have_many :invoices_items }
    it { expect(subject).to have_many :items }
    it { expect(subject).to have_many :invoices_bills_categories_templates }
    it { expect(subject).to have_many :receipts_invoices }
    it { expect(subject).to have_many :receipts }
    it { expect(subject).to have_many :accounting_transactions }
  end

  describe "Behaviors" do
    context "when paid" do
      subject { FactoryGirl.create :paid_invoice }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end

      it "should not be changed amount lower than paid amount" do
        ii = subject.invoices_items.first
        expect(subject.update_attributes({invoices_items_attributes: [{id: ii.id, item_id: ii.item_id, amount: ii.amount / 2}]})).to be_false
      end
    end

    context "has same reference with another" do
      let(:invoice) { FactoryGirl.create :invoice }
      subject { FactoryGirl.build(:invoice, :reference => invoice.reference) }
      it "should not be saved" do
        expect(subject.save).to be_false
      end
    end
  end
end
