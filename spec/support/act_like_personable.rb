shared_examples "a personable" do
  describe "Personable Validations" do
    it { expect(subject).to validate_uniqueness_of(:company_id).scoped_to(:builder_id) }
  end

  describe "Personable Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :company }

    it { expect(subject).to have_many :payments }
    it { expect(subject).to have_many :receipts }
    it { expect(subject).to have_many :bills }
    it { expect(subject).to have_many :projects_payers }
    it { expect(subject).to have_many :accounting_transactions }
  end

  describe "Behavior" do
    context "delegate" do
      it { should delegate_method(:company_name).to(:company) }
      it { should delegate_method(:city).to(:company) }
      it { should delegate_method(:state).to(:company) }
    end

    context "has payments" do
      subject { FactoryGirl.create "has_payments_#{described_class.name.underscore}".to_sym }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end

    context "has receipts" do
      subject { FactoryGirl.create "has_receipts_#{described_class.name.underscore}".to_sym }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end

    context "has bills" do
      subject { FactoryGirl.create "has_bills_#{described_class.name.underscore}".to_sym }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end

    context "has purchase_orders" do
      subject { FactoryGirl.create "has_purchase_orders_#{described_class.name.underscore}".to_sym }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end
  end
end