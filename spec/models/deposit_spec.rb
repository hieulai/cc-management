require 'spec_helper'

describe Deposit do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:builder) }
    it { expect(subject).to validate_presence_of(:account) }
    it { expect(subject).to validate_presence_of(:date) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :account }

    it { expect(subject).to have_many :deposits_receipts }
    it { expect(subject).to have_many :receipts }
    it { expect(subject).to have_many :accounting_transactions }
  end

  describe "Behaviors" do
    context "after create" do
      subject { FactoryGirl.create :deposit }
      it "should create transactions" do
        expect(subject.accounting_transactions).not_to be_empty
      end

      it "should create a transaction for Deposits Held account" do
        dhat = subject.accounting_transactions.accounts(subject.builder.deposits_held_account.id).non_project_accounts.first
        expect(dhat).not_to be_nil
      end

      it "should create a transaction for Bank account" do
        at = subject.accounting_transactions.accounts(subject.account.id).first
        expect(at).not_to be_nil
      end
    end
  end
end
