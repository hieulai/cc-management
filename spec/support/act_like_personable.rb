shared_examples "a personable" do
  describe "Personable Associations" do
    it { expect(subject).to have_many :payments }
    it { expect(subject).to have_many :receipts }
    it { expect(subject).to have_many :bills }
    it { expect(subject).to have_many :projects_payers }
    it { expect(subject).to have_many :accounting_transactions }
  end
end