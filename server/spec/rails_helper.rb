# typed: false
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "sidekiq/testing"
require "mocha/api"
require "factory_bot"
require "shoulda/matchers"
require "timecop"
require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)
Sidekiq::Testing.inline!

# Auto-load support files
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.use_active_record = false
  config.mock_with :mocha

  # FactoryBot
  config.include FactoryBot::Syntax::Methods
  FactoryBot.find_definitions

  # Sidekiq jobs isolation
  config.before { Sidekiq::Worker.clear_all }

  # Time helpers (travel_to, freeze_time, etc.)
  config.include ActiveSupport::Testing::TimeHelpers
  Timecop.safe_mode = true

  # Mailer helpers
  config.include ActionMailer::TestHelper

  # View & tag helpers (for view specs or presenter tests)
  config.include ActionView::Helpers::TagHelper
  config.include ActionView::Helpers::TextHelper
  config.include ActionView::Context

  config.include Dry::Monads[:result, :maybe] if defined?(Dry::Monads)

  # Match spec file location to behavior type (e.g. `:controller`, `:job`)
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  require 'database_cleaner-mongoid'

  RSpec.configure do |config|
    config.before(:suite) do
      DatabaseCleaner[:mongoid].strategy = :deletion
      DatabaseCleaner[:mongoid].clean_with(:deletion)
    end

    config.before(:each) do
      DatabaseCleaner[:mongoid].start
    end

    config.after(:each) do
      DatabaseCleaner[:mongoid].clean
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
