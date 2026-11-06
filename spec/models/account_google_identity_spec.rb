# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account do
  let(:auth) do
    OmniAuth::AuthHash.new(provider: 'google', uid: 'google-123',
      info: { email: 'new@example.com', first_name: 'Alex', last_name: 'Smith', name: 'Alex Smith',
              image: 'https://lh3.googleusercontent.com/profile-photo' },
      extra: { raw_info: { email_verified: true } })
  end

  it 'creates a confirmed account with its own profile' do
    account = described_class.from_omniauth(auth)
    expect(account).to be_confirmed
    expect(account.user.first_name).to eq('Alex')
    expect(account.user.avatar_url).to eq(auth.info.image)
  end

  it 'reuses the provider identity without creating another profile' do
    account = described_class.from_omniauth(auth)
    expect { described_class.from_omniauth(auth) }.not_to change { User.count }
    expect(described_class.from_omniauth(auth)).to eq(account)
  end

  it 'does not authenticate an existing person with the same name' do
    existing = create(:user, first_name: 'Alex', last_name: 'Smith')
    account = described_class.from_omniauth(auth)
    expect(account).not_to eq(existing.account)
    expect(account.user).not_to eq(existing)
  end

  it 'does not automatically link an existing email account' do
    existing = create(:account, email: auth.info.email)
    expect { described_class.from_omniauth(auth) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(existing.reload.provider).to be_nil
  end

  it 'rejects unverified Google email addresses' do
    auth.extra.raw_info.email_verified = false
    expect { described_class.from_omniauth(auth) }.to raise_error(ArgumentError)
  end

  it 'rejects missing provider identifiers' do
    auth.uid = ''
    expect { described_class.from_omniauth(auth) }.to raise_error(ArgumentError)
  end

  it 'rolls back account creation when the profile is invalid' do
    auth.info.first_name = 'A'
    expect do
      expect { described_class.from_omniauth(auth) }.to raise_error(ActiveRecord::RecordInvalid)
    end.not_to change { described_class.count }
  end

  it 'fills a missing photo for the existing provider identity without resetting profile details' do
    account = described_class.from_omniauth(auth)
    account.user.update!(avatar_url: nil, preferred_name: 'Pow Alex', about: 'My own profile', ride_type: :snowboard)
    expect { described_class.from_omniauth(auth) }.not_to change { User.count }
    profile = account.user.reload
    expect(profile.avatar_url).to eq(auth.info.image)
    expect(profile).to have_attributes(preferred_name: 'Pow Alex', about: 'My own profile', ride_type: 'snowboard')
  end

  it 'preserves an existing chosen avatar instead of replacing it with the provider image' do
    account = described_class.from_omniauth(auth)
    account.user.update!(avatar_url: 'https://example.com/chosen-photo.jpg')
    described_class.from_omniauth(auth)
    expect(account.user.reload.avatar_url).to eq('https://example.com/chosen-photo.jpg')
  end

  it 'does not change a locked account or invent a missing provider photo' do
    account = described_class.from_omniauth(auth)
    account.user.update!(avatar_url: nil)
    auth.info.image = nil
    described_class.from_omniauth(auth)
    expect(account.user.reload.avatar_url).to be_nil
    account.lock_access!
    auth.info.image = 'https://lh3.googleusercontent.com/new-photo'
    described_class.from_omniauth(auth)
    expect(account.user.reload.avatar_url).to be_nil
  end

  it 'fills the image without rejecting an existing legacy profile with incomplete fields' do
    account = described_class.from_omniauth(auth)
    # Reproduce an imported row predating required profile fields.
    account.user.update_columns(avatar_url: nil, ride_type: nil) # rubocop:disable Rails/SkipsModelValidations
    expect { described_class.from_omniauth(auth) }.not_to raise_error
    expect(account.user.reload.avatar_url).to eq(auth.info.image)
  end
end
