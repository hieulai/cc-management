require 'spec_helper'

describe CategoriesTemplate do
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:template) }
    it { expect(subject).to validate_presence_of(:category) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :template }
    it { expect(subject).to belong_to :category }
    it { expect(subject).to have_many :bills_categories_templates }
    it { expect(subject).to have_many :bills }
    it { expect(subject).to have_many :purchase_orders_categories_templates }
    it { expect(subject).to have_many :purchase_orders }

    it { expect(subject).to have_and_belong_to_many :items }
    it { expect(subject).to have_and_belong_to_many :accounts }
  end

  describe "Behaviors" do
    context "when category belongs to template already" do
      let(:template) {FactoryGirl.create :has_categories_templates_template}
      subject { FactoryGirl.build :categories_template, template: template, category: template.categories_templates.first.category }
      it "should not be added duplicately" do
        expect(subject.save).to be_false
      end
    end

    context "when belongs to estimate" do
      subject { FactoryGirl.create :belong_to_estimate_categories_template }
      it "should create GL accounts" do
        expect(subject.revenue_account).not_to be_nil
        expect(subject.cogs_account).not_to be_nil
      end
    end

    context "has paid bills" do
      subject { FactoryGirl.create :has_paid_bills_categories_template }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end

    context "has bills belong to an inovoice" do
      subject { FactoryGirl.create :has_invoiced_bills_categories_template }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end

    context "after delete" do
      subject { FactoryGirl.create :belong_to_estimate_categories_template }
      it "should delete its items" do
        subject.destroy
        expect(subject.items).to be_empty
      end

      it "should delete its GL accounts" do
        r_account_id = subject.revenue_account
        c_account_id = subject.cogs_account
        subject.destroy
        expect(Account.exists?(r_account_id)).to be_false
        expect(Account.exists?(c_account_id)).to be_false
      end

      it "should delete its category" do
        category_id = subject.category.id
        subject.destroy
        expect(Category.exists?(category_id)).to be_false
      end
    end
  end
end