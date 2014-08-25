require 'spec_helper'

describe PurchaseOrder do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:payer_id) }
    it { expect(subject).to validate_presence_of(:payer_type) }
    it { expect(subject).to validate_presence_of(:estimate) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :estimate }
    it { expect(subject).to belong_to :payer }
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :vendor }

    it { expect(subject).to have_one :bill }
    it { expect(subject).to have_many :purchase_orders_categories_templates }
    it { expect(subject).to have_many :categories_templates }
  end

  describe "Behaviors" do
    context "after create" do
      subject { FactoryGirl.create :purchase_order }
      it "should generate a bill" do
        expect(subject.bill).not_to be_nil
      end

      it "should create transactions for Cost of Goods Sold account" do
        poct = subject.purchase_orders_categories_templates.first
        expect(poct.accounting_transactions).not_to be_empty
        at = poct.accounting_transactions.accounts(poct.categories_template.cogs_account.id).non_project_accounts.first
        expect(at).not_to be_nil
      end

      it "should create transactions for Cost of Goods Sold account per project" do
        poct = subject.purchase_orders_categories_templates.first
        expect(poct.accounting_transactions).not_to be_empty
        at = poct.accounting_transactions.accounts(poct.categories_template.cogs_account.id).project_accounts(subject.project.id).first
        expect(at).not_to be_nil
      end
    end

    context "when amount is $0" do
      subject { FactoryGirl.build :zero_amount_purchase_order }
      it "should not be saved" do
        expect(subject.save).to be_false
      end
    end

    context "when has paid bill" do
      subject { FactoryGirl.create :paid_purchase_order }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end


      it "should not be changed amount lower than paid amount" do
        poct = subject.purchase_orders_categories_templates.first
        poi = poct.purchase_orders_items.first
        expect(subject.update_attributes(
                   {purchase_orders_categories_templates_attributes: [{id: poct.id, :purchase_orders_items_attributes =>
                       [{id: poi.id, actual_cost: poi.actual_cost / 2}]}]})).to be_false
      end
    end
  end
end
