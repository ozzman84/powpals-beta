# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Private house invitations' do
  include Devise::Test::IntegrationHelpers

  let(:manager) { create(:user) }
  let(:recipient) { create(:user) }
  let(:house) { create(:lodging) }
  let(:invitation) { house.house_invitations.create!(email: recipient.account.email, invited_by: manager.account) }

  before do
    create(:roommate, lodging: house, user: manager, role: :lease_holder)
  end

  it 'hides house navigation and rejects direct entry and self-enrollment for an ordinary skier' do
    sign_in recipient.account
    get user_path
    expect(response.body).not_to include('My houses', 'Ski Housing')
    get users_lodgings_path
    expect(response).to have_http_status(:forbidden)
    post users_lodgings_path, params: { lodging: { title: 'Uninvited' } }
    expect(response).to have_http_status(:forbidden)
  end

  it 'grants access only after the matching recipient accepts a valid invitation' do
    token = invitation.token
    expect(recipient.lodgings).to be_empty
    sign_in recipient.account
    get house_invitation_path(token: token)
    expect(response).to have_http_status(:ok)
    patch house_invitation_path(token: token)
    expect(recipient.lodgings).to contain_exactly(house)
    expect(invitation.reload.accepted_at).to be_present
    get users_lodging_path(house)
    expect(response).to have_http_status(:ok)
    expect { invitation.accept!(recipient.account) }.to raise_error(ArgumentError)
  end

  it 'does not disclose an invitation or accept it for the wrong account' do
    sign_in manager.account
    get house_invitation_path(token: invitation.token)
    expect(response).to have_http_status(:forbidden)
    expect { invitation.accept!(manager.account) }.to raise_error(ArgumentError)
    expect(invitation.reload.accepted_at).to be_nil
  end

  it 'rejects expired and revoked invitations without adding memberships' do
    invitation.update!(expires_at: 1.minute.ago)
    expect { invitation.accept!(recipient.account) }.to raise_error(ArgumentError)
    invitation.update!(expires_at: 1.day.from_now, revoked_at: Time.current)
    expect { invitation.accept!(recipient.account) }.to raise_error(ArgumentError)
    expect(recipient.lodgings).to be_empty
  end

  it 'stores only the token digest and prevents cross-house revocation' do
    expect(invitation.token_digest).not_to eq(invitation.token)
    other_house = create(:lodging)
    other_invite = other_house.house_invitations.create!(email: recipient.account.email, invited_by: manager.account)
    sign_in manager.account
    expect do
      delete users_lodging_roommate_path(house, other_invite)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
