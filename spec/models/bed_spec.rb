require 'rails_helper'

RSpec.describe Bed, type: :model do
  describe "relationships" do
    it { should belong_to(:room) }
  end
end
