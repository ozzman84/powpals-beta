# frozen_string_literal: true

require 'capybara/cuprite'

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [390, 844], headless: true,
    browser_options: { 'no-sandbox' => nil }, timeout: 15)
end
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by :cuprite }
end
