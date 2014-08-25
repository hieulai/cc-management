require 'spec_helper'

describe Transfer do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:from_account) }
    it { expect(subject).to validate_presence_of(:to_account) }
    it { expect(subject).to validate_presence_of(:date) }
    it { expect(subject).to validate_presence_of(:amount) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :from_account }
    it { expect(subject).to belong_to :to_account }

    it { expect(subject).to have_many :accounting_transactions }
  end

  describe "Behaviors" do
    context "after create" do
      subject { FactoryGirl.create :transfer }
      it "should create a transaction for from account" do
        at = subject.accounting_transactions.accounts(subject.from_account_id).first
        expect(at).not_to be_nil
      end

      it "should create a transaction for to account" do
        at = subject.accounting_transactions.accounts(subject.to_account_id).first
        expect(at).not_to be_nil
      end
    end
  end
end
