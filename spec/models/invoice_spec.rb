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

    it { expect(subject).to have_many :invoices_accounts }
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

    context "after save" do
      subject { FactoryGirl.create :invoice }

      it "should update remaning amount" do
        expect(subject.remaining_amount).to eq(subject.total_amount)
      end

      it "should create transactions" do
        expect(subject.accounting_transactions).not_to be_empty
      end

      it "should create Invoice accounts for categories" do
        expect(subject.invoices_accounts).not_to be_empty
        subject.invoices_accounts.each do |ia|
          expect(ia.account.parent).to eq(subject.builder.revenue_account)
        end
      end

      it "should create a transaction for Client" do
        at = subject.accounting_transactions.payer_accounts(subject.estimate.project.client_id, Client.name).non_project_accounts.first
        expect(at).not_to be_nil
      end

      it "should create a transaction for Payer per project" do
        at = subject.accounting_transactions.payer_accounts(subject.estimate.project.client_id, Client.name).project_accounts(subject.project.id).first
        expect(at).not_to be_nil
      end

      it "should create a transaction for Accounts Receivable account" do
        at = subject.accounting_transactions.accounts(subject.builder.accounts_receivable_account.id).non_project_accounts.first
        expect(at).not_to be_nil
      end

      it "should create a transaction for Accounts Receivable account per project" do
        at = subject.accounting_transactions.accounts(subject.builder.accounts_receivable_account.id).project_accounts(subject.project.id).first
        expect(at).not_to be_nil
      end

      it "should create transactions for Revenue accounts" do
        ia = subject.invoices_accounts.first
        at = ia.accounting_transactions.non_project_accounts.first
        expect(at).not_to be_nil
      end

      it "should create transactions for Revenue accounts per project" do
        ia = subject.invoices_accounts.first
        at = ia.accounting_transactions.project_accounts(subject.project.id).first
        expect(at).not_to be_nil
      end
    end

  end
end
