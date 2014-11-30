require 'pty'

module RSpec

  module Cli

    ##
    # This class spawns your process and provides some
    # helpers to interact with the process
    class CliProcess
      TERMINAL_COLOURS = /\e\[(\d+)(;\d+)*m/

      attr_reader :pid, :kill_signal

      def initialize(*args)
        raise ArgumentError, "wrong number of arguments" if args.empty?
        args.unshift(*args.shift) if Array === args.first

        @command = args
      end

      def read(len = 100)
        raise "process hasn't spawned yet" if @pid.nil?
        # read from @master (master part of pseudo terminal) where program output is going
        out = ""
        begin
          loop do
            # Arbitraty choice of 100 bytes. Not sure if this is good/bad
            out << @master.read_nonblock(len)
          end
        rescue
          if out.empty?
            return nil
          else
            return out.gsub(TERMINAL_COLOURS, '')
          end
        end

      end

      def write(arg)
        raise "process hasn't spawned yet" if @pid.nil?
        # Writing to a pipe stdin so our ptm doesn't fill with buffered input
        @in.puts arg
      end

      def run!
        # Create master and slave pseudo terminal devices

        @master, @slave = PTY.open
        # Create a unix pipe with read/write file descriptors
        @out, @in = IO.pipe
        # spawn our process and set the process's input to be the
        # read endpoint of the pipe
        # set it's output to be the slave pseudo device
        r, w, @pid = PTY.spawn(*@command, in: @out, out: @slave)
        # close the read file descriptor for the pipe in this process,
        # our spawned process will still have this as their stdout
        @out.close
        # close the connection to the slave pseudo device. The spawned
        # process will still be connected to this
        @slave.close

        self
      end

      def status
        raise "process hasn't spawned yet" if @pid.nil?
        PTY.check(@pid)
      end

      def alive?
        begin
          return status.nil?
        rescue
          return false
        end
      end

      def dying?
        @kill_signal != nil && alive?
      end

      def kill(signal = "TERM")
        raise "Process hasn't spawned yet" if @pid.nil?
        @in.close
        @master.close
        Process.kill(signal, @pid)
        @kill_signal = signal
      end
    end
  end
end
