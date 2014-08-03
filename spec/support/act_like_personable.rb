shared_examples "a personable" do
  describe "Personable Associations" do
    it { expect(subject).to have_many :payments }
    it { expect(subject).to have_many :receipts }
    it { expect(subject).to have_many :bills }
    it { expect(subject).to have_many :projects_payers }
    it { expect(subject).to have_many :accounting_transactions }
  end

  describe "Behavior" do
    context "has payments" do
      let(:person) { FactoryGirl.create "has_payments_#{described_class.name.underscore}".to_sym }
      it "should not be deleted" do
        expect(person.destroy).to be_false
      end
    end

    context "has receipts" do
      let(:person) { FactoryGirl.create "has_receipts_#{described_class.name.underscore}".to_sym }
      it "should not be deleted" do
        expect(person.destroy).to be_false
      end
    end

    context "has bills" do
      let(:person) { FactoryGirl.create "has_bills_#{described_class.name.underscore}".to_sym }
      it "should not be deleted" do
        expect(person.destroy).to be_false
      end
    end

    context "has purchase_orders" do
      let(:person) { FactoryGirl.create "has_purchase_orders_#{described_class.name.underscore}".to_sym }
      it "should not be deleted" do
        expect(person.destroy).to be_false
      end
    end
  end
end