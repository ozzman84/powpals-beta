# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::LodgingCalendars', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/users/lodging_calendars/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/users/lodging_calendars/show'
      expect(response).to have_http_status(:success)
    end
  end
end
