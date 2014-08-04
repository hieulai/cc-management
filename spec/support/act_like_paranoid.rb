shared_examples "a paranoid" do
  subject { FactoryGirl.create described_class.name.demodulize.underscore.to_sym }

  describe "Acts_as_paranoid" do
    it do
      id = subject.id
      subject.destroy
      expect(described_class.with_deleted.exists?(id)).to be_true
    end
  end
end