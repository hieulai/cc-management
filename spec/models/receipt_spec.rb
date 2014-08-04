require 'spec_helper'

describe Receipt do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:builder) }
    it { expect(subject).to validate_presence_of(:method) }
    it { expect(subject).to validate_presence_of(:received_at) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :payer }
    it { expect(subject).to belong_to :client }

    it { expect(subject).to have_many :receipts_invoices }
    it { expect(subject).to have_many :invoices }
    it { expect(subject).to have_many :deposits_receipts }
    it { expect(subject).to have_many :deposits }
    it { expect(subject).to have_many :receipts_items }
    it { expect(subject).to have_many :accounting_transactions }
  end

  describe "Behaviors" do
    context "when paid" do
      subject { FactoryGirl.create :paid_receipt }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end

      it "should not be changed amount lower than paid amount" do
        ri = subject.receipts_items.first
        expect(subject.update_attributes({receipts_items_attributes: [{id: ri.id, amount: ri.amount / 2}]})).to be_false
      end
    end
  end
end
