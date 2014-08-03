require 'spec_helper'

describe Vendor do
  it_behaves_like "a personable"
  it_behaves_like "a profilable"
  it_behaves_like "a billable"
  it_behaves_like "a paranoid"

  describe "Behaviors" do
    context "has_bids" do
      subject { FactoryGirl.create :has_bids_vendor }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end
  end
end
