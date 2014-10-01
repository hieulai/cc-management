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

    context "after create" do
      subject { FactoryGirl.create :receipt }
      it "should update remaning amount" do
        expect(subject.remaining_amount).to eq(subject.total_amount)
      end

      it "should create a transaction for Payer" do
        expect(subject.accounting_transactions.payer_accounts(subject.payer_id, subject.payer_type).non_project_accounts).not_to be_empty
      end

      it "should create a transaction for Deposits Held account" do
        expect(subject.accounting_transactions.accounts(subject.builder.deposits_held_account.id)).not_to be_empty
      end

      context "as an uninvoiced receipt" do
        subject { FactoryGirl.create :receipt }
        it "should create transactions for GL accounts" do
          ri = subject.receipts_items.first
          at = subject.accounting_transactions.accounts(ri.account.id).first
          expect(at).not_to be_nil
          expect(at.payer).not_to be_nil
        end
      end

      context "as an client_receipt receipt" do
        subject { FactoryGirl.create :client_receipt_receipt }
        it "should create a transaction for Accounts Receivable account" do
          expect(subject.accounting_transactions.accounts(subject.builder.accounts_receivable_account.id).non_project_accounts).not_to be_empty
        end

        it "should create a transaction for Accounts Receivable account per project" do
          invoice = subject.invoices.first
          expect(subject.accounting_transactions.accounts(subject.builder.accounts_receivable_account.id).project_accounts(invoice.project.id)).not_to be_empty
        end

        it "should create a transaction for Payer per project" do
          invoice = subject.invoices.first
          expect(subject.accounting_transactions.payer_accounts(subject.client_id, Client.name).project_accounts(invoice.project.id)).not_to be_empty
        end

        it "should update client credit account for leftover amount" do
          expect(subject.accounting_transactions.where(payer_id: nil, payer_type: nil, account_id: subject.builder.client_credit_account.id)).not_to be_empty
          expect(subject.accounting_transactions.where(payer_id: subject.client_id, payer_type: Client.name, account_id: subject.builder.client_credit_account.id)).not_to be_empty
        end
      end
    end
  end
end
