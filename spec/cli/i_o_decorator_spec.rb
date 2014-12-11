require 'spec_helper'
require 'rspec/cli/i_o_decorator'

describe RSpec::Cli::IODecorator do



  let(:pipe_arry) { IO.pipe }

  let(:pipe_out) { pipe_arry[0] }
  let(:pipe_in) { pipe_arry[1] }

  let(:io_out) { RSpec::Cli::IODecorator.new pipe_out }
  let(:io_in) { RSpec::Cli::IODecorator.new pipe_in }


  describe "#has_data?" do

    it "returns true if io has data to read" do
      io_in.puts "test_data"
      expect(io_out.has_data?).to be true
    end

    it "returns false if io has no data to reads" do
      expect(io_out.has_data?).to be false
    end

  end

  describe "#read_all" do

    context "with nonblocking reads" do

      it 'returns nil if no data' do
        expect(io_out.read_all(nonblocking: true)).to be nil
      end

      it "returns all the data if there is data" do
        io_in.write "hi, this"
        io_in.write " is test data"
       expect(io_out.read_all(nonblocking: true)).to eq "hi, this is test data"
      end

      it "doesn't fall into a race condition with another process interacting with it" do
        master_tty, slave_tty = PTY.open

        master = RSpec::Cli::IODecorator.new master_tty

        command = "spec/support/bin/dummy --looper --sleeper 0.1"
        @pid =  PTY.spawn(command, in: slave_tty, out: slave_tty, err: slave_tty)[2]

        master.write "hi there"
        expect(master.read_all).to eq "hi there"
      end
    end


    context "with blocking reads" do

     it 'blocks till data arrives' do
       test = lambda do
         Timeout::timeout(1) { io_out.read_all }
       end

       expect(test).to raise_error Timeout::Error
     end

     it 'reads all the data when available' do

       data = nil
       huge_string = "BC" * 0xFFFF
       huge_string << "ends in awesome"

       # declare the block that we will call in our test
       test = lambda do
         Timeout::timeout(1) { data = io_out.read_all }
       end

       # the huge_string might be too big for the buffer and block
       # while the system waits for the buffer to be read from,
       # so we do the write in a new thread.
       Thread.new do
         io_in.write huge_string
       end

       expect(test).to change{data}.to huge_string

     end

    end

  end

end
