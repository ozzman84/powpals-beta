# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
require 'factory_bot_rails'

FactoryBot.create_list(:user, 10)
FactoryBot.create(:lodging)
Lodging.first.rooms << FactoryBot.create_list(:room, 2)
Room.first.beds << FactoryBot.create(:bed)
Room.second.beds << FactoryBot.create(:bed)