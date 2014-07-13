require 'spec_helper'

describe User do
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:email) }
    it { expect(subject).to validate_uniqueness_of(:email) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
  end

  it_behaves_like "a paranoid"
end
