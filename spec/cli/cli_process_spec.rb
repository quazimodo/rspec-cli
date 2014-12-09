require 'spec_helper'
require 'rspec/cli/cli_process'

describe RSpec::Cli::CliProcess do

  let(:looper) do
    RSpec::Cli::CliProcess.new(%w[spec/support/bin/dummy --looper])
  end

  let(:echo) do
    RSpec::Cli::CliProcess.new %w[spec/support/bin/dummy --echo "interesting repeat"]
  end



  it "initializes with a binary and a set of arguments" do
    expect{RSpec::Cli::CliProcess.new %w[echo who are you] }.not_to raise_error
  end

  it "initializes without actually spawning any process" do
    expect(PTY).not_to receive(:spawn)
    expect(echo.pid).to eq nil
  end

  describe "#run!" do

    it "spawns process and sets the pid" do
      echo.run!
      expect(echo.pid).not_to eq nil
    end

    it "assigns the new process's stdout to a tty by default" do
      allow_any_instance_of(File).to receive(:close)
      echo.run!
      expect(echo.stdout).to be_a_tty
    end

    it "assigns the new process's stdin to a tty by default" do
      allow_any_instance_of(File).to receive(:close)
      echo.run!
      expect(echo.stdin).to be_a_tty
    end

  end

  describe "#status" do

    it "raises an error if the process hasn't spawned yet" do
      expect{echo.status}.to raise_error "process hasn't spawned yet"
    end

    it "returns nil if the process is still alive" do
      looper.run!
      expect(looper.status).to eq nil
    end

    it "returns a Process::Status object if the process has spawned and terminated" do
      looper.run!
      looper.kill!
      sleep 0.1
      expect(looper.status).to be_a_kind_of Process::Status
    end

  end

  describe "#write" do

    it "writes to the spawned processes stdin" do
      looper.run!
      looper.write "hi there"
      expect(looper.gets).to include "hi there"
    end

    it "puts to the spawned process stdin" do
      looper.run!
      looper.puts "hi there"
      expect(looper.gets).to include "hi there"
    end

    it "raises an error if the process hasn't been spawned" do
      expect{looper.write "hi"}.to raise_error
    end

  end

  describe "#kill" do

    it "closes all remaining streams" do
      looper.run!
      pty = looper.instance_variable_get(:@master)
      expect(pty).to receive(:close)
      looper.kill!
    end

    it "raises an error if the process hasn't spawned" do
      expect{looper.read}.to raise_error
    end

    it "terminates the process using SIGTERM" do
      looper.run!
      pid = looper.pid
      expect(Process).to receive(:kill).with("TERM", pid).and_call_original
      looper.kill!
      expect(Process.wait looper.pid).to eq looper.pid
    end

    it "terminates the process using given signal" do
      looper.run!
      pid = looper.pid
      expect(Process).to receive(:kill).with("KILL", pid).and_call_original
      looper.kill!("KILL")
      expect(Process.wait looper.pid).to eq looper.pid
    end
  end
end
