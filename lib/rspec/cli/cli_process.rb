require 'pty'
require 'rspec/cli/i_o_decorator'

module RSpec

  module Cli

    ##
    # This class spawns your process and provides some
    # helpers to interact with the process
    class CliProcess

      TERMINAL_COLOURS = /\e\[(\d+)(;\d+)*m/

      attr_reader :pid

      def initialize(*args)
        raise ArgumentError, "wrong number of arguments" if args.empty?
        args.unshift(*args.shift) if Array === args.first
        @command = args
      end

      def flush
        assert_spawned
        @master.flush
      end

      def read_all(*args)
        assert_spawned
        @master.flush
        @master.read_all *args
      end

      def gets
        assert_spawned
        @master.gets
      end

      def puts(*args)
        assert_spawned
        @master.puts args
        @master.flush
      end

      def stdout
        @master
      end

      def stdin
        @slave
      end

      def write(arg)
        # This method can block if the argument is huge
        assert_spawned
        @master.write "#{arg}\n"
        @master.flush
      end

      def run!
        # Create master and slave pseudo terminal devices
        master_tty, slave_tty = PTY.open
        @master =  IODecorator.new master_tty
        @slave = slave_tty

        @pid =  PTY.spawn(*@command, in: @slave, out: @slave, err: @slave)[2]

        @slave.close

        self

      end

      def status

        assert_spawned
        PTY.check(@pid)

      end

      def alive?

        begin
          return status.nil?
        rescue
          return false
        end

      end

      def kill!(signal = "TERM")

        assert_spawned
        @master.close
        Process.kill(signal, @pid)

      end

      private

      def assert_spawned
        raise "process hasn't spawned yet" if @pid.nil?
      end

    end

  end

end
