# frozen_string_literal: true

# Error tracking (Sentry protocol - Sentry Cloud now, DSN-swappable to self-hosted GlitchTip
# later; the SDK is identical, only the DSN changes).
#
# Fully inert unless BOTH are true: we're in production AND a DSN is configured.
# The DSN lives in credentials (with an ENV fallback for flexibility):
#   rails credentials:edit  ->  sentry:\n    dsn: https://...@...ingest.../123
#
# So dev/test never initialize Sentry (a hard guarantee no local/CI error ever ships),
# and prod stays silent until the DSN is added - no code change needed to turn it on.

sentry_dsn = Rails.application.credentials.dig(:sentry, :dsn).presence || ENV['SENTRY_DSN'].presence

if Rails.env.production? && sentry_dsn
  Sentry.init do |config|
    config.dsn = sentry_dsn

    # Belt-and-suspenders alongside the Rails.env.production? guard above.
    config.enabled_environments = %w[production]

    # Privacy: never attach IP / cookies / user context by default. Request params are
    # additionally scrubbed via Rails.application.config.filter_parameters (email, token,
    # secret, passw, ... - see config/initializers/filter_parameter_logging.rb), which
    # sentry-rails honors automatically.
    config.send_default_pii = false

    # Errors are the goal, not performance tracing - keep tracing off to avoid noise/cost.
    config.traces_sample_rate = 0.0

    # Ties each error to the exact deploy when SENTRY_RELEASE is injected at deploy time
    # (e.g. the commit SHA from the CI deploy job). Harmless nil otherwise.
    config.release = ENV['SENTRY_RELEASE'].presence

    config.breadcrumbs_logger = %i[active_support_logger http_logger]

    # Solid Queue runs through ActiveJob, which sentry-rails instruments automatically,
    # so background-job failures are captured without extra wiring.
  end
end
