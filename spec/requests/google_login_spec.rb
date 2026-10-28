# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Google login' do
  let(:auth) do
    OmniAuth::AuthHash.new(provider: 'google', uid: 'verified-google-123',
      info: { email: 'google-login@example.com', first_name: 'Alex', last_name: 'Jones', name: 'Alex Jones' },
      extra: { raw_info: { email_verified: true } })
  end

  around do |example|
    previous_mode = OmniAuth.config.test_mode
    previous_mock = OmniAuth.config.mock_auth[:google]
    previous_auth = Rails.application.env_config['omniauth.auth']
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google] = auth
    Rails.application.env_config['omniauth.auth'] = auth
    example.run
  ensure
    OmniAuth.config.test_mode = previous_mode
    OmniAuth.config.mock_auth[:google] = previous_mock
    Rails.application.env_config['omniauth.auth'] = previous_auth
  end

  it 'signs in a verified Google account through the callback' do
    get account_google_omniauth_callback_path
    expect(response).to redirect_to(user_path)
    expect(Account.find_by!(provider: 'google', uid: auth.uid)).to be_confirmed
  end

  it 'does not bypass account locking through Google login' do
    account = Account.from_omniauth(auth)
    account.lock_access!
    get account_google_omniauth_callback_path
    expect(response).to redirect_to(new_account_session_path)
  end

  it 'rejects an unverified Google identity through the callback' do
    auth.extra.raw_info.email_verified = false
    get account_google_omniauth_callback_path
    expect(response).to redirect_to(new_account_session_path)
    expect(Account.where(uid: auth.uid)).not_to exist
  end
end
