# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Setup ActionMailer to deliver mail via sendmail
config.action_mailer.delivery_method = :sendmail
config.action_mailer.sendmail_settings = {
  :location       => '/usr/sbin/sendmail',
  :arguments      => '-i -t'
}
config.action_mailer.perform_deliveries = true

# This is a fix for Passenger and Rails 2.2.2.
config.action_controller.relative_url_root = "/books"