require 'rails_helper'

RSpec.describe Room, type: :model do
  describe "relationships" do
    it { should have_many(:beds) }
    it { should belong_to(:lodging) }
  end
end
