# frozen_string_literal: true

namespace :ski_days do
  desc 'Create account ski days for the next 10 days'
  task create_next_10_days: :environment do
    account_ids = Account.all.ids
    resort_ids = Resort.all.ids
    start_date = (Date.today..9.days.from_now).to_a
    # binding.pry
    10.times do
      AccountSkiDay.create(account_id: account_ids.sample, resort_id: resort_ids.sample, start_date: start_date.sample)
    end
    puts '10 account ski days created for the next 10 days.'
  end
end
