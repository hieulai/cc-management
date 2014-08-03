require 'spec_helper'

describe Client do
  it_behaves_like "a personable"
  it_behaves_like "a profilable"
  it_behaves_like "a billable"
  it_behaves_like "a paranoid"

  describe "Client Associations" do
    it { expect(subject).to have_many :projects }
    it { expect(subject).to have_many :invoices }
  end

  describe "Behaviors" do
    context "has_projects" do
      subject { FactoryGirl.create :has_projects_client }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end
  end
end
