require 'rails_helper'

RSpec.describe Photo, type: :model do
  describe "relationships" do
    it { should belong_to(:lodging) }
    it { should has_one_attached(:photo) }
  end
end
