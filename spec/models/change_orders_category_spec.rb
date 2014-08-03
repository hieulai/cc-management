require 'spec_helper'

describe ChangeOrdersCategory do
  it_behaves_like "a paranoid"
  describe "Associations" do
    it { expect(subject).to belong_to :change_order }
    it { expect(subject).to belong_to :category }
    it { expect(subject).to have_many :items }
    it { expect(subject).to have_and_belong_to_many :accounts }
  end

  describe "Behaviors" do
    context "after create" do
      subject { FactoryGirl.create :change_orders_category }
      it "should create GL accounts" do
        expect(subject.revenue_account).not_to be_nil
        expect(subject.cogs_account).not_to be_nil
      end
    end

    context "after delete" do
      subject { FactoryGirl.create :change_orders_category }
      it "should delete its GL accounts" do
        r_account_id = subject.revenue_account
        c_account_id = subject.cogs_account
        subject.destroy
        expect(Account.exists?(r_account_id)).to be_false
        expect(Account.exists?(c_account_id)).to be_false
      end
    end

    context "has billed items" do
      subject { FactoryGirl.create :has_billed_items_change_orders_category }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end

    context "has invoiced items" do
      subject { FactoryGirl.create :has_invoiced_items_change_orders_category }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end
  end
end
