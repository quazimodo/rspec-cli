require "rspec/cli/version"
require "rspec/cli/cli_process"

module RSpec

  module Cli

    def spawn_cli_process(*args)
      new_cli_process(*args).run!
    end

    def new_cli_process(*args)
      CliProcess.new(*args)
    end

  end

end
