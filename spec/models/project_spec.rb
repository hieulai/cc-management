require 'spec_helper'

describe Project do
  it_behaves_like "a paranoid"
  describe "Validations" do
    it { expect(subject).to validate_presence_of(:name) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :client }
    it { expect(subject).to belong_to :builder }

    it { expect(subject).to have_many :estimates }
    it { expect(subject).to have_many :change_orders }
    it { expect(subject).to have_many :projects_payers }
    it { expect(subject).to have_many :invoices }
    it { expect(subject).to have_one :tasklist }
  end

  describe "Behavior" do
    context "has undestroyable estimates project" do
      subject { FactoryGirl.create :has_undestroyable_estimates_project }
      it "should not be deleted" do
        expect(subject.destroy).to be_false
      end
    end

    context "when status changed" do
      context "attempts to be a project" do
        context "has estimate" do
          subject { FactoryGirl.create(:current_lead_has_estimates_project) }
          before { subject.update_attribute(:status, Project::CURRENT) }
          it "should commit estimate" do
            expect(subject.committed_estimate).not_to be_nil
          end
          it "should set client to active state" do
            expect(subject.client.status).to eq(Client::ACTIVE)
          end
        end
        context "has no estimate" do
          subject { FactoryGirl.create(:current_lead_project) }
          it "should not set to project state" do
            expect(subject.update_attribute(:status, Project::CURRENT)).to be_false
          end
        end
      end
      context "attempts to be a lead" do
        subject { FactoryGirl.create(:current_project) }
        before { subject.update_attribute(:status, Project::CURRENT_LEAD) }
        it "should set client to lead state" do
          expect(subject.client.status).to eq(Client::LEAD)
        end
        it "should uncommit estimate" do
          expect(subject.committed_estimate).to be_nil
        end
      end
    end

    context "when client changed" do
      it "should update transactions" do
         #TODO: implement later
      end
    end
  end
end
