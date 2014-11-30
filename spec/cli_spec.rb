require 'spec_helper'
require 'rspec/cli'

describe RSpec::Cli do

  let(:subject) { Object.new.extend RSpec::Cli }

  describe "::new_cli_process" do

    it "returns a CliProcess object that has not actually spawned the process yet" do
      p = subject.new_cli_process %w[factor]
      expect(p.pid).to eq nil
    end

  end

  describe "::spawn_cli_process" do

    it "returns a CliProcess object with a spawned process" do
      p = subject.spawn_cli_process %w[factor]
      expect(p.pid).not_to eq nil
    end

  end

end
