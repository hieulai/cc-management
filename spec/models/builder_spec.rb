require 'spec_helper'

describe Base::Builder do
  it_behaves_like "a paranoid"
  describe "Associations" do
    it { expect(subject).to have_many :clients }
    it { expect(subject).to have_many :projects }
    it { expect(subject).to have_many :estimates }
    it { expect(subject).to have_many :users }
    it { expect(subject).to have_many :items }
    it { expect(subject).to have_many :categories }
    it { expect(subject).to have_many :templates }
    it { expect(subject).to have_many :accounts }
    it { expect(subject).to have_many :tasklists }
    it { expect(subject).to have_many :vendors }
    it { expect(subject).to have_many :contacts }
    it { expect(subject).to have_many :prospects }
    it { expect(subject).to have_many :receipts }
    it { expect(subject).to have_many :bills }
    it { expect(subject).to have_many :purchase_orders }
    it { expect(subject).to have_many :payments }
    it { expect(subject).to have_many :invoices }
    it { expect(subject).to have_many :deposits }
    it { expect(subject).to have_many :bids }
    it { expect(subject).to have_many :specifications }
  end

  subject { FactoryGirl.create :builder }
  describe "Accounts" do
    it "should generate Default accounts" do
      expect(subject.accounts).to have(Account::DEFAULTS.size).item
    end

    Account::DEFAULTS.each do |n|
      it "has #{n} account" do
        expect(subject.send("#{n.parameterize.underscore}_account".to_sym)).to_not be_nil
        expect(subject.send("#{n.parameterize.underscore}_account").name).to eq(n)
      end
    end
  end
end
