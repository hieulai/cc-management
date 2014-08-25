require 'spec_helper'

describe Payment do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:builder) }
    it { expect(subject).to validate_presence_of(:account) }
    it { expect(subject).to validate_presence_of(:date) }
    it { expect(subject).to validate_presence_of(:method) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :account }
    it { expect(subject).to belong_to :vendor }
    it { expect(subject).to belong_to :payer }

    it { expect(subject).to have_many :payments_bills }
    it { expect(subject).to have_many :bills }
    it { expect(subject).to have_many :accounting_transactions }
  end

  describe "Behaviors" do
    context "after create" do
      subject { FactoryGirl.create :payment }
      it "should create transactions" do
        expect(subject.accounting_transactions).not_to be_empty
      end

      it "should create a transaction for Payer" do
        at = subject.accounting_transactions.payer_accounts(subject.payer_id, subject.payer_type).non_project_accounts.first
        expect(at).not_to be_nil
      end

      it "should create a transaction for Payer per project" do
        bill = subject.bills.first
        at = subject.accounting_transactions.payer_accounts(subject.payer_id, subject.payer_type).project_accounts(bill.project.id).first
        expect(at).not_to be_nil
      end

      it "should create a transaction for Account Payable account" do
        at = subject.accounting_transactions.accounts(subject.builder.accounts_payable_account.id).non_project_accounts.first
        expect(at).not_to be_nil
      end

      it "should create transactions for Account Payable account per project" do
        bill = subject.bills.first
        at = subject.accounting_transactions.accounts(subject.builder.accounts_payable_account.id).project_accounts(bill.project.id).first
        expect(at).not_to be_nil
      end

      it "should create a transaction for Bank account" do
        at = subject.accounting_transactions.accounts(subject.account.id).non_project_accounts.first
        expect(at).not_to be_nil
      end

      it "should create transactions for Bank account per project" do
        bill = subject.bills.first
        at = subject.accounting_transactions.accounts(subject.account.id).project_accounts(bill.project.id).first
        expect(at).not_to be_nil
      end
    end
  end
end
