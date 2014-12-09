require 'pty'
require 'delegate'

module RSpec

  module Cli

    class IODecorator < SimpleDelegator

      def has_data?(timeout = 0)
        IO.select([self], nil, nil, timeout) ? true : false
      end

      def read_all nonblocking = false
        return nil if nonblocking and not has_data?

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
