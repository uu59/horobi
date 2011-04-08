# -- coding: utf-8

require "rubygems"

module Horobi
  module Hub
    def start

      @options = {
        "logfile" => STDERR,
        "input" => "5551",
        "output" => "5552",
      }
      OptionParser.new do |op|
        op.on('-p VAL','--pidfile=VAL','pidfile path'){|v| @options["pidfile"] = v}
        op.on('-l VAL','--logfile=VAL','logfile path'){|v| @options["logfile"] = (v == "-" ? STDOUT : v)}
        op.on('-i VAL','--input-port=VAL','input(pull) point such as 5551'){|v| @options["input"] = v}
        op.on('-o VAL','--output-port=VAL','output(pub) point such as 5552'){|v| @options["output"] = v}
        op.on('-d','--daemonize','daemonize this script'){ @options["daemonize"] = true }
        op.parse!(ARGV)
      end

      @logger = Logger.new(@options["logfile"])
      
      if @options["daemonize"]
        Horobi.daemonize
        @logger.debug("mainloop running ##{Process.pid}")
      end

      if @options["pidfile"]
        File.open(@options["pidfile"],"w"){|fp| fp.write Process.pid}
      end

      begin
        @context = ZMQ::Context.new
        @input  = @context.socket(ZMQ::PULL)
        @input.bind("tcp://127.0.0.1:#{@options["input"]}")
        @logger.info("input socket listen at #{@options["input"]}")
        @output = @context.socket(ZMQ::PUB)
        @output.bind("tcp://127.0.0.1:#{@options["output"]}")
        @logger.info("output socket listen at #{@options["output"]}")
      rescue TypeError => ex
        puts "invalid port. input:#{@options["input"]}, output:#{@options["output"]}"
        exit!
      end

      Horobi.close_hooks do
        @logger.info("hub stopping")
        stop
      end

      loop do
        sleep 0.1
        next unless inp = @input.recv(ZMQ::NOBLOCK)
        @output.send(inp)
        @logger.debug(inp)
      end

      exit!
    end

    def stop
      begin
        @logger.info("stopping..")
        @input.close if @input
        @output.close if @output
      rescue IOError
        # in `recv': closed socket (IOError)
      ensure
        if @options["pidfile"]
          File.delete(@options["pidfile"])
        end
        @context.close
      end
    end

    extend self
  end
end
