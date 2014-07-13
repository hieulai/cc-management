shared_examples "a paranoid" do
  let(:paranoid) { FactoryGirl.create described_class.name.demodulize.underscore.to_sym }

  describe "Acts_as_paranoid" do
    it do
      id = paranoid.id
      paranoid.destroy
      expect(described_class.with_deleted.exists?(id)).to be_true
    end
  end
end