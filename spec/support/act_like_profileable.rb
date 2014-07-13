shared_examples "a profilable" do
  describe "Profilable Associations" do
    it { expect(subject).to have_many :profiles }
  end
end