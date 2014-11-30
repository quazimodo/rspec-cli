Dir.glob(::File.expand_path('../support/*.rb', __FILE__)).each { |f| require_relative f }

RSpec.configure do |config|

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end
end
