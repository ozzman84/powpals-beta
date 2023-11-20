# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before { create(:user).account }

  describe 'GET /index' do
    # it 'returns http success' do
    #   get users_path
    #   expect(response).to have_http_status(:success)
    # end
  end

  describe 'GET /show' do
    # it 'returns http success' do
    #   get user_path
    #   expect(response).to have_http_status(:success)
    # end
  end

  describe 'GET /edit' do
    # it 'returns http success' do
    #   get edit_user_path(User.first)
    #   expect(response).to have_http_status(:success)
    # end
  end
end
