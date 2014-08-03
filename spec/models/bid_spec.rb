require 'spec_helper'

describe Bid do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:builder) }
    it { expect(subject).to validate_presence_of(:project) }
    it { expect(subject).to validate_presence_of(:category) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :project }
    it { expect(subject).to belong_to :estimate }
    it { expect(subject).to belong_to :vendor }
    it { expect(subject).to belong_to :category }

    it { expect(subject).to have_many :bids_items }
  end
end
