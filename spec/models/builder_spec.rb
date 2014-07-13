require 'spec_helper'

describe Base::Builder do

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

  let(:builder) { FactoryGirl.create :builder }
  describe "Accounts" do
    it "generate Default accounts" do
      expect(builder.accounts).to have(Account::DEFAULTS.size).item
    end

    Account::DEFAULTS.each do |n|
      it "has #{n} account" do
        expect(builder.send("#{n.parameterize.underscore}_account".to_sym)).to_not be_nil
        expect(builder.send("#{n.parameterize.underscore}_account").name).to eq(n)
      end
    end
  end

  it_behaves_like "a paranoid"
end
