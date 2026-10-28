# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account access' do
  include Devise::Test::IntegrationHelpers

  it 'registers a profile and sends confirmation instructions' do
    expect do
      post account_registration_path, params: { account: { email: 'signup@example.com', password: 'Password123!',
                                                           password_confirmation: 'Password123!',
                                                           user_attributes: { first_name: 'Alex', last_name: 'Jones',
                                                                              ride_type: 'ski' } } }
    end.to change { Account.count }.by(1)
    account = Account.find_by!(email: 'signup@example.com')
    expect(account).not_to be_confirmed
    expect(account.user.first_name).to eq('Alex')
    expect(response).to redirect_to(new_account_session_path)
  end

  it 'requires the current password to change account credentials' do
    account = create(:account)
    create(:user, account: account)
    sign_in account
    put account_registration_path, params: { account: { email: 'replacement@example.com', current_password: 'wrong' } }
    expect(account.reload.email).not_to eq('replacement@example.com')
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'does not register an account without the required profile' do
    expect do
      post account_registration_path, params: { account: { email: 'incomplete@example.com', password: 'Password123!',
                                                           password_confirmation: 'Password123!' } }
    end.not_to change { Account.count }
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'accepts nested pass selections without accepting account ownership overrides' do
    user = create(:user)
    pass = create(:season_pass)
    sign_in user.account
    patch edit_profile_path, params: { account: { account_season_passes_attributes: {
      '0' => { season_pass_id: pass.id, account_id: create(:account).id }
    } } }
    expect(user.account.reload.season_passes).to contain_exactly(pass)
  end
end
