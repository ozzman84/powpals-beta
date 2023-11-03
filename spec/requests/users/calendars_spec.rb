require 'rails_helper'

RSpec.describe "Users::Calendars", type: :request do
  let(:current_account) { create(:account) }
  let(:user) { create(:user, account: current_account) }
  let(:lodging) { create(:lodging) }
  let!(:roommate) { Roommate.create(lodging: lodging, user: user) }

  describe "GET /show" do
    # it "returns http success" do
    #   get users_lodging_calendars_path(lodging)
    #   # binding.pry
    #   expect(response).to have_http_status(:success)
    # end
  end

  describe "GET /my_calendar" do
    # it "returns http success" do
    #   get my_calendar_users_lodging_calendars_path(lodging)
    #   expect(response).to have_http_status(:success)
    # end
  end
end
