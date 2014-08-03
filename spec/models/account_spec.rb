require 'spec_helper'

describe Account do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to validate_uniqueness_of(:name).scoped_to(:builder_id, :parent_id) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :parent }

    it { expect(subject).to have_many :payments }
    it { expect(subject).to have_many :deposits }
    it { expect(subject).to have_many :children }
    it { expect(subject).to have_many :sent_transfers }
    it { expect(subject).to have_many :received_transfers }
    it { expect(subject).to have_many :receipts_items }
    it { expect(subject).to have_many :un_job_costed_items }
    it { expect(subject).to have_many :accounting_transactions }
    it { expect(subject).to have_one :accounting_transaction }

    it { expect(subject).to have_and_belong_to_many :categories_templates }
    it { expect(subject).to have_and_belong_to_many :change_orders_categories }
    it { expect(subject).to have_and_belong_to_many :invoices_items }
    it { expect(subject).to have_and_belong_to_many :invoices_bills_categories_templates }
  end

  describe "Behaviors" do
    context "as a Normal account" do
      subject { FactoryGirl.create :account }
      it 'should not allow self reference' do
        expect(subject.update_attribute(:parent_id, subject.id)).to be_false
      end
    end

    context "as a Default account" do
      let(:builder) { FactoryGirl.create :builder }
      subject { builder.bank_accounts_account }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end

      it "should not be renamed" do
        expect(subject.update_attribute(:name, "smt")).to be_false
      end

      it "should not be updated parent" do
        expect(subject.update_attribute(:parent_id, 1)).to be_false
      end
    end

    context "as a non Bank account" do
      let(:builder) { FactoryGirl.create :builder }
      subject { builder.assets_account }
      it "should not be updated opening_balance" do
        expect(subject.update_attributes({opening_balance: 100, opening_balance_updated_at: Date.today})).to be_false
      end
    end

    context "as a Bank account" do
      context "update opening_balance" do
        let(:builder) { FactoryGirl.create :builder }
        subject { builder.bank_accounts_account }

        it 'should not be done without date' do
          expect(subject.update_attribute(:opening_balance, 100)).to be_false
        end
        it 'should be done with date' do
          expect(subject.update_attributes({opening_balance: 100, opening_balance_updated_at: Date.today})).to be_true
        end

        it 'should has opening_balance transaction' do
          expect(subject.accounting_transaction).not_to be_nil
        end
      end
    end
  end

end
