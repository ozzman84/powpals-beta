require 'rails_helper'

RSpec.describe "Users::Photos", type: :request do
  describe "GET /index" do
    it "returns http success" do
      lodging = create(:lodging)
      get users_lodging_photos_path(lodging)

      expect(response).to have_http_status(:success)
    end
  end

end
