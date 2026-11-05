# frozen_string_literal: true

# Cookies are shared across ports; keep fictional-demo sessions separate from Bear Lodge.
if Rails.env.development? && ENV['POWPALS_DATABASE'] == 'powpals_beta_demo_development'
  Rails.application.config.session_store :cookie_store, key: '_powpals_demo_session'
end
