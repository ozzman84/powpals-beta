# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account do
  let(:auth) do
    OmniAuth::AuthHash.new(provider: 'google', uid: 'google-123',
      info: { email: 'new@example.com', first_name: 'Alex', last_name: 'Smith', name: 'Alex Smith' },
      extra: { raw_info: { email_verified: true } })
  end

  it 'creates a confirmed account with its own profile' do
    account = described_class.from_omniauth(auth)
    expect(account).to be_confirmed
    expect(account.user.first_name).to eq('Alex')
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
end
