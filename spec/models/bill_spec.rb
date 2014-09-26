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

    context "after create" do
      subject { FactoryGirl.create :bill }
      it "should create transactions" do
        expect(subject.accounting_transactions).not_to be_empty
      end

      it "should create a transaction for payer" do
        at = subject.accounting_transactions.payer_accounts(subject.payer_id, subject.payer_type).non_project_accounts.first
        expect(at).not_to be_nil
      end

      it "should create a transaction for payer per project" do
        at = subject.accounting_transactions.payer_accounts(subject.payer_id, subject.payer_type).project_accounts(subject.project.id).first
        expect(at).not_to be_nil
      end

      it "should update remaning amount" do
        expect(subject.remaining_amount).to eq(subject.total_amount)
      end

      context "as a job costed bill" do
        subject { FactoryGirl.create :bill }
        it "should create a transaction for Accounts Payable account" do
          at = subject.accounting_transactions.accounts(subject.builder.accounts_payable_account.id).first
          expect(at).not_to be_nil
        end

        it "should create transactions for Cost of Goods Sold account" do
          bct = subject.bills_categories_templates.first
          expect(bct.accounting_transactions).not_to be_empty
          at = bct.accounting_transactions.accounts(bct.categories_template.cogs_account.id).non_project_accounts.first
          expect(at).not_to be_nil
        end

        it "should create transactions for Cost of Goods Sold account per project" do
          bct = subject.bills_categories_templates.first
          expect(bct.accounting_transactions).not_to be_empty
          at = bct.accounting_transactions.accounts(bct.categories_template.cogs_account.id).project_accounts(subject.project.id).first
          expect(at).not_to be_nil
        end
      end

      context "as an unjob costed bill" do
        subject { FactoryGirl.create :unjob_costed_bill }
        it "should create transactions" do
          expect(subject.accounting_transactions).not_to be_empty
        end

        it "should create a transaction for Accounts Payable account" do
          pat = subject.accounting_transactions.accounts(subject.builder.accounts_payable_account.id).first
          expect(pat).not_to be_nil
        end

        it "should create transactions for GL accounts" do
          ujci = subject.un_job_costed_items.first
          pat = subject.accounting_transactions.accounts(ujci.account.id).first
          expect(pat).not_to be_nil
        end
      end
    end

    context "when paid" do
      subject { FactoryGirl.create :paid_bill }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end

      it "should not be changed amount lower than paid amount" do
        bct = subject.bills_categories_templates.first
        bi = bct.bills_items.bill(subject.id).first
        expect(subject.update_attributes(
                   bills_categories_templates_attributes: [{id: bct.id, :bills_items_attributes =>
                       [{id: bi.id, actual_cost: bi.actual_cost / 2}]}])).to be_false
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
