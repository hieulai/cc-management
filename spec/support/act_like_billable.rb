shared_examples "a billable" do
  describe "Billable Associations" do
    it { expect(subject).to have_many :bills }
    it { expect(subject).to have_many :purchase_orders }
  end
end