require 'pty'
require 'delegate'
require 'timeout'

module RSpec

  module Cli

    class IODecorator < SimpleDelegator

      def has_data?(timeout = 0)
        IO.select([self], nil, nil, timeout) ? true : false
      end

      # This fails on huge data blocks. the has_data? thing migth be
      # returning false when the system is about to refill the stream
      # with more data. Essentially a race condition
      def read_all nonblocking = false
        if nonblocking && !has_data?
          return nil
        end

        # Block until data has arrived.
        data = readpartial 0xFFFF
        # If there is more data in the buffer, retrieve it nonblocking.
        while has_data?
          data << readpartial(0xFFFF)
        end
        data
      end

    end

  end

end
