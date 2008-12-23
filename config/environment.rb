# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = {
    :session_key => '_BookConnection_session',
    :secret      => 'd971121f900360c5082259862185f5d3f2e9f66475e5d21f779fae4eb43881f93ab1ed36e8ba69768c0b828ad4157337bc205b43412cd674ca251bc04c82ae1e'
  }
  
  config.load_paths << "#{RAILS_ROOT}/app/mailers"
end

ExceptionNotifier.exception_recipients = %w{seifersays@gmail.com}
ExceptionNotifier.email_prefix = "[Book Connection ERROR] "