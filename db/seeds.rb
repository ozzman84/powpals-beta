# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
require "factory_bot_rails"

user = FactoryBot.create(:account).user = FactoryBot.create(:user)
lodging = FactoryBot.create(:lodging)
Roommate.create(user_id: user.id, lodging_id: lodging.id)

10.times do
    FactoryBot.create(:account).user = FactoryBot.create(:user)
end