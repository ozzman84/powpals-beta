# frozen_string_literal: true

# Explicit demo seeding preserves the original factory-driven development workflow,
# but refuses the real revival, historical and production databases.
if ENV['POWPALS_DEMO'] == 'true'
  Rails.logger.info JSON.pretty_generate(DemoSeedData.new.call)
else
  Rails.logger.info 'No demo records added. Set POWPALS_DEMO=true on the separate demo database to seed samples.'
end
