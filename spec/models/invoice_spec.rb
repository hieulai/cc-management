require 'spec_helper'

describe Invoice do
  it_behaves_like "a paranoid"

  describe "Validations" do
    it { expect(subject).to validate_presence_of(:builder) }
    it { expect(subject).to validate_presence_of(:estimate) }
  end

  describe "Associations" do
    it { expect(subject).to belong_to :builder }
    it { expect(subject).to belong_to :estimate }

    it { expect(subject).to have_many :invoices_items }
    it { expect(subject).to have_many :items }
    it { expect(subject).to have_many :invoices_bills_categories_templates }
    it { expect(subject).to have_many :receipts_invoices }
    it { expect(subject).to have_many :receipts }
    it { expect(subject).to have_many :accounting_transactions }
  end
end
