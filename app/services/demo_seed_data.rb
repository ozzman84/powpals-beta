# frozen_string_literal: true

class DemoSeedData
  PASSWORD = 'PowPals-Demo-Only-2026!'
  EMAIL = 'demo@powpals.test'
  PEOPLE = [%w[Alex Rider], %w[Jordan Snow], %w[Casey Summit], %w[Taylor Woods], %w[Morgan Peak],
    %w[Riley Frost]].freeze

  def call
    require_demo_database!
    require 'factory_bot_rails'
    FactoryBot.find_definitions unless FactoryBot.factories.registered?(:account)
    ApplicationRecord.transaction do
      HistoricalCatalogImport.new.call(JSON.parse(Rails.root.join('db/historical_catalog.json').read))
      users = PEOPLE.each_with_index.map { |name, index| create_person(name, index) }
      ['Bear Lodge', 'Summit Cabin', 'Snow Chalet'].each { |name| create_house("Demo #{name}", users) }
    end
    { email: EMAIL, houses: Lodging.count, people: User.count, resorts: Resort.count, passes: SeasonPass.count }
  end

  private

  def require_demo_database!
    return if Rails.env.development? && ENV['DATABASE_URL'].blank? &&
      ApplicationRecord.connection_db_config.database == 'powpals_beta_demo_development'

    raise ArgumentError, 'Demo seeds require the separate powpals_beta_demo_development database'
  end

  def create_person(name, index)
    email = index.zero? ? EMAIL : "pal#{index}@powpals.test"
    account = Account.find_by(email: email) || FactoryBot.create(:account, email: email,
      password: PASSWORD, sign_in_count: 0)
    user = account.user || FactoryBot.create(:user, account: account, first_name: name.first, last_name: name.last,
      full_name: name.join(' '), preferred_name: name.first, city: 'Frisco', state: 'CO',
      about: 'Fictional demo skier, separate from the real house.', ride_type: :ski, level: :intermediate)
    AccountSeasonPass.find_or_create_by!(account: account, season_pass: SeasonPass.order(:id).first)
    Resort.order(:id).limit(3).each do |resort|
      AccountSkiDay.find_or_create_by!(account: account, resort: resort, start_date: Date.current + index)
    end
    user
  end

  def create_house(title, users)
    house = Lodging.find_by(title: title) || FactoryBot.create(:lodging, title: title, max_guests: 12, max_cars: 8,
      description: 'Fictional demo house with populated rooms, stays and accounting examples.',
      street: '1 Example Lane', address2: nil, city: 'Frisco', state: 'CO', zip_code: '80443', status: :published,
      season_start: season_start, season_end: season_start.next_year - 6.months - 1.day)
    users.each_with_index do |user, index|
      Roommate.find_or_create_by!(lodging: house, user: user) do |member|
        member.role = index.zero? ? :lease_holder : :roommate
      end
      create_stays(house, user, index)
    end
    create_rooms(house)
    create_season(house)
  end

  def season_start
    year = Date.current.month >= 5 ? Date.current.year : Date.current.year - 1
    Date.new(year, 11, 1)
  end

  def create_stays(house, user, index)
    date = [Date.current, house.season_start].max
    7.times do |offset|
      night = date + offset
      next if night > house.season_end

      Calendar.find_or_create_by!(lodging: house, user: user, date: night) do |stay|
        stay.status = (index + offset).even? ? :staying : :away
        stay.guest_count = (stay.staying? && index.zero? ? 1 : 0)
        stay.cars = stay.staying? ? 1 : 0
      end
    end
  end

  def create_rooms(house)
    { 'Master suite' => 'king', 'Queen room' => 'queen', 'Bunk room' => 'twin' }.each do |name, size|
      room = house.rooms.find_or_create_by!(name: name) { |record| record.room_type = :bedroom }
      room.beds.find_or_create_by!(size: size, style: :mattress)
    end
  end

  def create_season(house)
    season = house.house_seasons.find_or_create_by!(starts_on: house.season_start,
      ends_on: house.season_end) do |record|
      record.name = 'Demo winter season'
      record.policy_status = :confirmed
      record.guest_rates = Date::DAYNAMES.index_with { |day| %w[Monday Tuesday Wednesday].include?(day) ? 3000 : 5000 }
      record.monthly_rent_cents = 630_000
      record.participant_count = 6
      record.rules = 'Demo rules: members have bed priority. Finish laundry, dishes and trash before departing.'
    end
    entry = season.house_ledger_entries.find_or_create_by!(source_key: 'demo-fee') do |record|
      record.kind = :guest_fee
      record.description = 'Fictional weekend guest fees'
      record.month_on = [Date.current.beginning_of_month, house.season_start].max
      record.amount_cents = 10_000
    end
    return if entry.house_payments.any?

    entry.record_payment!(amount_cents: 4000, paid_on: Date.current, recorded_by: house.users.first.account,
      reference: 'Fictional demo receipt; no money transferred')
  end
end
