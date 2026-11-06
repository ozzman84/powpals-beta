# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Seasonal house directory' do
  include Devise::Test::IntegrationHelpers

  let(:manager) { create(:user) }
  let(:person) { create(:user, phone_number: 'PRIVATE-PHONE') }
  let(:house) { create(:lodging) }
  let(:season) do
    house.house_seasons.create!(name: 'Winter', starts_on: Date.current, ends_on: Date.current + 30)
  end

  let(:member) { create(:roommate, user: person, lodging: house) }
  let!(:details) { season.house_season_memberships.create!(roommate: member, responsibilities: 'Trash coordinator') }

  before do
    create(:roommate, user: manager, lodging: house, role: :lease_holder)
    sign_in manager.account
  end

  it 'reuses profiles without exposing private contact details by default' do
    get users_lodging_house_members_path(house, season_id: season.id)
    expect(response.body).to include('Trash coordinator')
    expect(response.body).not_to include('PRIVATE-PHONE', person.account.email)
    details.update!(share_contact: true)
    get users_lodging_house_members_path(house, season_id: season.id)
    expect(response.body).to include('PRIVATE-PHONE')
  end

  it 'allows a member to edit their pets and consent without granting themselves responsibilities or status' do
    sign_in person.account
    patch users_lodging_house_member_path(house, details, season_id: season.id), params: {
      house_season_membership: { pets: 'Example dog', share_contact: true, responsibilities: 'Accountant',
                                 status: 'former' }
    }
    expect(details.reload).to have_attributes(pets: 'Example dog', share_contact: true,
      responsibilities: 'Trash coordinator', status: 'active')
    expect(member.reload).to be_roommate
  end

  it 'does not accept another house season or membership ID' do
    other_house = create(:lodging)
    foreign_season = other_house.house_seasons.create!(name: 'Other', starts_on: Date.current,
      ends_on: Date.current + 30)
    expect do
      get users_lodging_house_members_path(house, season_id: foreign_season.id)
    end.to raise_error(ActiveRecord::RecordNotFound)
    foreign_member = create(:roommate, lodging: other_house)
    expect(season.house_season_memberships.new(roommate: foreign_member)).not_to be_valid
  end

  it 'preserves previous season details while accepting an invitation into a new season' do
    new_season = house.house_seasons.create!(name: 'Next winter', starts_on: Date.current.next_year,
      ends_on: Date.current.next_year + 30)
    invitation = house.house_invitations.create!(email: person.account.email, invited_by: manager.account,
      house_season: new_season)
    invitation.accept!(person.account)
    expect(member.house_season_memberships.count).to eq(2)
    expect(details.reload.responsibilities).to eq('Trash coordinator')
    expect(new_season.house_season_memberships.first.responsibilities).to be_nil
  end

  it 'removes private access for a former current-season member and restores it only through acceptance' do
    house.update!(season_start: season.starts_on, season_end: season.ends_on)
    details.update!(status: :former)
    sign_in person.account
    get users_lodging_house_members_path(house, season_id: season.id)
    expect(response).to have_http_status(:forbidden)
    expect(person.reload.house_access?).to be(false)
    invitation = house.house_invitations.create!(email: person.account.email, invited_by: manager.account,
      house_season: season)
    invitation.accept!(person.account)
    expect(details.reload).to be_status_active
    expect(person.reload.house_access?).to be(true)
  end

  it 'allows a manager to revoke access without deleting history or letting a member revoke other users' do
    patch users_lodging_roommate_path(house, member), params: { roommate: { access_state: 'revoked' } }
    expect(member.reload).to be_access_revoked
    expect(details.reload).to be_present
    sign_in person.account
    get users_lodging_path(house)
    expect(response).to have_http_status(:forbidden)
  end

  it 'shows contact actions on portrait cards only with consent for the selected season' do
    house.update!(season_start: season.starts_on, season_end: season.ends_on)
    person.update!(preferred_name: 'Snow Pal', phone_number: '+1 (202) 555-0142')
    [users_lodging_path(house), users_lodging_house_members_path(house, season_id: season.id)].each do |path|
      get path
      card = Nokogiri::HTML(response.body).at_css("[data-roommate-card='#{member.id}']")
      expect(card.text).to include('Snow Pal', 'Contact details not shared')
      expect(card.css('a[href^="mailto:"], a[href^="tel:"]')).to be_empty
    end
    details.update!(share_contact: true)
    [users_lodging_path(house), users_lodging_house_members_path(house, season_id: season.id)].each do |path|
      get path
      card = Nokogiri::HTML(response.body).at_css("[data-roommate-card='#{member.id}']")
      expect(card.at_css('a[href^="mailto:"]')['href']).to eq("mailto:#{person.account.email}")
      expect(card.at_css('a[href^="tel:"]')['href']).to eq('tel:+12025550142')
    end
  end

  it 'allows members to share their own social links without exposing private ones or granting roles' do
    sign_in person.account
    patch users_lodging_house_member_path(house, details, season_id: season.id), params: {
      house_season_membership: { social_links: [
        { label: 'Instagram', url: 'https://www.instagram.com/', shared: 'true' },
        { label: 'Website', url: 'https://example.com/private', shared: 'false' }
      ], role: 'admin' }
    }
    expect(details.reload.shared_social_links.map { |link| link['label'] }).to eq(['Instagram'])
    expect(member.reload).to be_roommate
    sign_in manager.account
    get users_lodging_house_members_path(house, season_id: season.id)
    card = Nokogiri::HTML(response.body).at_css("[data-roommate-card='#{member.id}']")
    expect(card.at_css('a[href="https://www.instagram.com/"]')).to be_present
    expect(card.to_html).not_to include('https://example.com/private')
    patch users_lodging_house_member_path(house, details, season_id: season.id), params: {
      house_season_membership: { pets: 'Example dog',
                                 social_links: [{ label: 'Website', url: 'https://example.com/changed', shared: true }] }
    }
    expect(details.reload.social_links.size).to eq(2)
    sign_in person.account
    patch users_lodging_house_member_path(house, details, season_id: season.id), params: {
      house_season_membership: { social_links: [{ label: 'Bad link', url: 'javascript:alert(1)', shared: true }] }
    }
    expect(details.reload.social_links.size).to eq(2)
  end
end
