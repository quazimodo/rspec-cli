require 'spec_helper'
require 'rspec/cli/cli_process'
require 'pry'

describe Rspec::Cli::CliProcess do

  let(:subject) { Rspec::Cli::CliProcess.new %w[echo who are you] }

  it "initializes with a binary and a set of arguments" do
    expect{Rspec::Cli::CliProcess.new %w[echo who are you] }.not_to raise_error
  end


  it "initializes without actually spawning any process" do
    expect(PTY).not_to receive(:spawn)
    p = Rspec::Cli::CliProcess.new %w[echo who are you]
    expect(p.pid).to eq nil
  end

  describe "#run!" do

    after(:each) {subject.kill}

    it "spawns the process" do
      expect(PTY).to receive(:spawn).and_call_original
      subject.run!
    end

    it "sets the pid" do
      subject.run!
      expect(subject.pid).not_to eq nil
    end

    it "assigns the new process's stdout to a tty by default" do
      allow_any_instance_of(File).to receive(:close)
      subject.run!
      expect(subject.instance_variable_get(:@slave).isatty).to be true
    end

    it "assigns the new process's stdin to a pipe endpoint by default" do
      allow_any_instance_of(IO).to receive(:close)
      subject.run!
      expect(FileTest.pipe? subject.instance_variable_get(:@out)).to be true
    end

  end

  describe "#status" do

    it "raises an error if the process hasn't spawned yet" do
      subject = Rspec::Cli::CliProcess.new %w[echo who are you]
      expect{subject.status}.to raise_error "process hasn't spawned yet"
    end

    it "returns nil if the process is still alive" do
      subject = Rspec::Cli::CliProcess.new(%w[factor]).run!
      expect(subject.status).to eq nil
      subject.kill
    end

    it "returns a Process::Status object if the process has spawned and terminated" do
      subject = Rspec::Cli::CliProcess.new(%w[factor]).run!
      subject.kill
      sleep 0.1
      expect(subject.status).to be_a_kind_of Process::Status
    end

  end

  describe "#write" do

    it "writes to the spawned processes stdin" do
      subject = Rspec::Cli::CliProcess.new(%w[factor]).run!
      stdin = subject.instance_variable_get :@in
      expect(stdin).to receive(:puts).with("hi there")
      subject.write "hi there"
    end

    it "raises an error if the process hasn't been spawned" do
      subject = Rspec::Cli::CliProcess.new(%w[factor])
      expect{subject.write "hi"}.to raise_error
    end

  end


  describe "#read" do

    let(:arg) do
      arg = "this is a very long set of data to output."
      arg << " In fact, it should be longer than 100 bytes."
      arg << " And it should be more than 100 bytes by now."
      arg
    end

    it "reads the whole output from the stdout" do
      subject = Rspec::Cli::CliProcess.new(["echo", arg ]).run!
      sleep 0.1
      expect(subject.read).to eq "#{arg}\r\n"
    end

    it "reads without blocking" do
      subject = Rspec::Cli::CliProcess.new(%w[factor]).run!
      sleep 0.1
      expect(subject.read).to eq nil
    end

    it "raises an error if the process hasn't spawned" do
      subject = Rspec::Cli::CliProcess.new(%w[factor])
      expect{subject.read}.to raise_error
    end

    it "removes terminal colours from output" do
      arg = "\e[0;32msome text and some color codes\e[0m"
      subject = Rspec::Cli::CliProcess.new(["echo", arg]).run!
      sleep 0.1
      expect(subject.read).to eq "some text and some color codes\r\n"
    end

    it "returns nil if there is nothing to read" do
      subject = Rspec::Cli::CliProcess.new(%w[echo hi]).run!
      sleep 0.1
      subject.read
      expect(subject.read).to eq nil
    end

  end

  describe "#kill" do



  end
end
