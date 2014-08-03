require 'spec_helper'

describe User do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:email) }
    it { expect(subject).to validate_uniqueness_of(:email) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
  end
end
