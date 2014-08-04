require 'spec_helper'

describe Bill do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:builder) }
    it { expect(subject).to validate_presence_of(:billed_date) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :estimate }
    it { expect(subject).to belong_to :payer }
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :purchase_order }

    it { expect(subject).to have_many :payments_bills }
    it { expect(subject).to have_many :payments }
    it { expect(subject).to have_many :un_job_costed_items }
    it { expect(subject).to have_many :accounting_transactions }
    it { expect(subject).to have_many :bills_categories_templates }
    it { expect(subject).to have_many :categories_templates }
  end

  describe "Behaviors" do
    context "when amount is $0" do
      subject { FactoryGirl.build :zero_amount_bill }
      it "should not be saved" do
        expect(subject.save).to be_false
      end
    end

    context "when paid" do
      subject { FactoryGirl.create :paid_bill }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end

      it "should not be changed amount lower than paid amount" do
        bct = subject.bills_categories_templates.first
        bi = bct.bills_items.first
        expect(subject.update_attributes(
                   {bills_categories_templates_attributes: [{id: bct.id, :bills_items_attributes =>
                       [{id: bi.id, actual_cost: bi.actual_cost / 2}]}]})).to be_false
      end
    end

    context "when belong to an invoice" do
      subject { FactoryGirl.create :invoiced_bill }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end

  end
end
