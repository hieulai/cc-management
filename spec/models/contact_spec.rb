require 'spec_helper'

describe Contact do
  it_behaves_like "a personable"
  it_behaves_like "a profilable"
  it_behaves_like "a billable"
end
